# = About libcraigscrape.rb
#
# All of libcraigscrape's objects and methods are loaded when you use <tt>require 'libcraigscrape'</tt> in your code.
#
require 'net/http'
require 'zlib'

require 'rubygems'
require 'hpricot'
require 'htmlentities'
require 'activesupport'

# A base class encapsulating the libcraigscrape objests, and providing some utility methods.
class CraigScrape
  cattr_accessor :time_now
    
  class BadUrlError < StandardError #:nodoc:
  end
  
  class ParseError < StandardError #:nodoc: 
  end

  class FetchError < StandardError #:nodoc:
  end
    
  # Returns the most recentlt expired  time for the provided month and day
  def self.most_recently_expired_time(month, day)  #:nodoc:
    now = (time_now) ? time_now : Time.now
    
    # This ensures we always generate a time in the past, by guessing the year and subtracting one if we guessed wrong
    ret = Time.local now.year, month, day
    ret = Time.local now.year-1, month, day if ret > now 
    
    ret
  end

  class Scraper #:nodoc:
    cattr_accessor :logger
    cattr_accessor :sleep_between_fetch_retries
    cattr_accessor :retries_on_fetch_fail

    # Returns the full url that corresponds to this resource
    attr_reader :url

    # Set some defaults:
    self.retries_on_fetch_fail = 4
    self.sleep_between_fetch_retries = 4
  
    class BadConstructionError < StandardError; end
    class UnrecognizedPageError < StandardError; end
    class ParseError < StandardError; end
  
    HTML_TRIM = /(?:^(?:[\s]+|<br[\s]*[\/]?>)(.*)|(.*)(?:<br[\s]*[\/]?>|[\s]+)$)/mi
  
    def initialize(init_via = nil)
      if init_via.nil?
        # Do nothing - possibly not a great idea, but we'll allow it
      elsif init_via.kind_of? String
        @url = init_via
      elsif init_via.kind_of? Hash
        init_via.each_pair{|k,v| instance_variable_set "@#{k}", v}
      else
        raise BadConstructionError, ("Unrecognized parameter passed to %s.new %s}" % [self.class.to_s, init_via.class.inspect])
      end
    end
    
    private
    
    # Returns text with all html entities converted to respective ascii character.
    def he_decode(text)
      self.class.he_decode text
    end
    
    def self.he_decode(text)
      HTMLEntities.new.decode text
    end
    
    def fetch_url(uri) #:nodoc:
  
      logger.info "Requesting: %s" % @url if logger
  
      case uri.scheme
        when 'file'
          File.read uri.path
        when /^http[s]?/
          fetch_attempts = 0
          
          begin
            # This handles the redirects for us          
            resp, data = Net::HTTP.new( uri.host, uri.port).get uri.request_uri, nil
        
            if resp.response.code == "200"
              # Check for gzip, and decode:
              data = Zlib::GzipReader.new(StringIO.new(data)).read if resp.response.header['Content-Encoding'] == 'gzip'
              
              data
            elsif resp.response['Location']
              redirect_to = resp.response['Location']
              # TODO: Here's where we fix that / redirect bug
              self.fetch_url(redirect_to)
            else
              # Sometimes Craigslist seems to return 404's for no good reason, and a subsequent fetch will give you what you want
              error_description = 'Unable to fetch "%s" (%s)' % [ @url, resp.response.code ]
      
              logger.info error_description if logger
              
              raise FetchError, error_description
            end
          rescue FetchError => err
            fetch_attempts += 1
            
            if retries_on_fetch_fail <= self.retries_on_fetch_fail
              sleep self.sleep_between_fetch_retries if self.sleep_between_fetch_retries
              retry
            else
              raise err
            end
          end
        else
          raise BadUrlError, "Unknown URI scheme for the url: #{@url}"
      end
    end
    
    def uri
      @uri ||= URI.parse @url if @url
      @uri
    end
    
    def html
      @html ||= Hpricot.parse fetch_url(uri) if uri
      @html
    end
  end


  # PostFull represents a fully downloaded, and parsed, Craigslist post.
  # This class is generally returned by the listing scrape methods, and 
  # contains the post summaries for a specific search url, or a general listing category 
  class PostFull < Scraper
    
    POST_DATE      = /Date:[^\d]*((?:[\d]{2}|[\d]{4})\-[\d]{1,2}\-[\d]{1,2}[^\d]+[\d]{1,2}\:[\d]{1,2}[ ]*[AP]M[^a-z]+[a-z]+)/i
    LOCATION       = /Location\:[ ]+(.+)/
    POSTING_ID     = /PostingID\:[ ]+([\d]+)/
    REPLY_TO       = /(.+)/
    PRICE          = /\$([\d]+(?:\.[\d]{2})?)/
    HTML_TAG       = /<\/?[^>]*>/
    USERBODY_PARTS = /\<div id\=\"userbody\">(.+)\<br[ ]*[\/]?\>\<br[ ]*[\/]?\>(.+)\<\/div\>/m


    # Create a new Post via a url (String), or supplied parameters (Hash)
    def initialize(*args)
      super(*args)


      # Validate that required fields are present:
# TODO:
#      raise ParseError, "Unable to parse PostFull: %s" % html.to_html if !flagged_for_removal? and !deleted_by_author? and [
#        @contents,@posting_id,@post_time,@header,title,@full_section
#      ].any?{|f| f.nil? or (f.respond_to? :length and f.length == 0)}
    end
        

    # String, The contents of the item's html body heading
    def header
      unless @header
        h2 = html.at('h2')
        @header = he_decode h2.inner_html if h2
      end
      
      @header
    end
    
    # String, the item's title
    def title
      unless @title
        title_tag = html.at('title')
        @title = he_decode title_tag.inner_html if title_tag
        @title = nil if @title and @title.length == 0
      end
    
      @title
    end

    # Array, hierarchial representation of the posts section
    def full_section
      unless @full_section
        @full_section = []
        (html/"div[@class='bchead']//a").each do |a|
          @full_section << he_decode(a.inner_html) unless a['id'] and a['id'] == 'ef'
        end
      end

      @full_section
    end

    # String, represents the post's reply-to address, if listed
    def reply_to
      unless @reply_to
        cursor = html.at 'hr'    
        cursor = cursor.next_sibling until cursor.nil? or cursor.name == 'a'
        @reply_to = $1 if cursor and REPLY_TO.match he_decode(cursor.inner_html)
      end
      
      @reply_to
    end
    
    # Time, reflects the full timestamp of the posting 
    def post_time
      unless @post_time
        cursor = html.at 'hr'
        cursor = cursor.next_node until cursor.nil? or POST_DATE.match cursor.to_s
        @post_time = Time.parse $1 if $1
      end
      
      @post_time
    end

    # Integer, Craigslist's unique posting id
    def posting_id
      unless @posting_id
        cursor = (html/"#userbody").first
        cursor = cursor.next_node until cursor.nil? or POSTING_ID.match cursor.to_s
        @posting_id = $1.to_i if $1
      end
    
      @posting_id
    end
    
    # String, The full-html contents of the post
    def contents
      unless @contents
        @contents = user_body
        @contents = he_decode @contents.strip if @contents
      end
      
      @contents
    end
    
    # String, the location of the item, as best could be parsed
    def location
      if @location.nil? and craigslist_body
        # Location (when explicitly defined):
        cursor = craigslist_body.at 'ul' unless @location
        
        # Apa section includes other things in the li's (cats/dogs ok fields)
        cursor.children.each do |li|
          if LOCATION.match li.inner_html
            @location = he_decode($1) and break
            break
          end
        end if cursor

        # Real estate listings can work a little different for location:
        unless @location
          cursor = craigslist_body.at 'small'
          cursor = cursor.previous_node until cursor.nil? or cursor.text?
          
          @location = he_decode(cursor.to_s.strip) if cursor
        end
      end
      
      @location
    end

    # Array, urls of the post's craigslist-hosted images
    def images
      unless @images
        @images = []
        
        if craigslist_body
          # Now let's find the craigslist hosted images:
          img_table = (craigslist_body / 'table').find{|e| e.name == 'table' and e[:summary] == 'craigslist hosted images'}
        
          @images = (img_table / 'img').collect{|i| i[:src]} if img_table
        end
      end
      
      @images
    end

    # Returns true if this Post was parsed, and merely a 'Flagged for Removal' page
    def flagged_for_removal?
      @flagged_for_removal = (
        system_post? and header_as_plain == "This posting has been flagged for removal"
      ) if @flagged_for_removal.nil?
      
      @flagged_for_removal
    end
    
    # Returns true if this Post was parsed, and represents a 'This posting has been deleted by its author.' notice
    def deleted_by_author?
      @deleted_by_author = (
        system_post? and header_as_plain == "This posting has been deleted by its author."
      ) if @deleted_by_author.nil?
    end
     
    # Returns the price (as float) of the item, as best ascertained by the post header
    def price
      $1.to_f if title and header and PRICE.match(header.gsub(/#{title}/, ''))
    end
    
    # Returns the post contents with all html tags removed
    def contents_as_plain
      contents.gsub HTML_TAG, "" if contents
    end

    # Returns the header with all html tags removed. Granted, the header should usually be plain, but in the case of a 
    # 'system_post' we may get tags in here
    def header_as_plain
      header.gsub HTML_TAG, "" if header
    end

    # Some posts (deleted_by_author, flagged_for_removal) are common template posts that craigslist puts up in lieu of an original 
    # This returns true or false if that case applies
    def system_post?
      [contents,posting_id,post_time,title].all?{|f| f.nil?}
    end

    private

    # OK - so the biggest problem parsing the contents of a craigslist post is that users post invalid html all over the place
    # This bad html trips up hpricot, and I've resorted to splitting the page up using string parsing like so:
    # We return this as a string, since it makes sense, and since its tough to say how hpricot might mangle this if the html is whack
    def user_body     
      $1 if USERBODY_PARTS.match html.to_s
    end
    
    # Read the notes on user_body. However,  unlike the user_body, the craigslist portion of this div can be relied upon to be valid html. 
    # So - we'll return it as an Hpricot object.
    def craigslist_body
      Hpricot.parse $2 if USERBODY_PARTS.match html.to_s
    end

  end

  # Listings represents a parsed Craigslist listing page and is generally returned by CraigScrape.scrape_listing
  class Listings < Scraper
    LABEL          = /^(.+?)[ ]*\-$/
    LOCATION       = /^[ ]*\((.*?)\)$/
    IMG_TYPE       = /^[ ]*(.+)[ ]*$/
    HEADER_DATE    = /^[ ]*[^ ]+[ ]+([^ ]+)[ ]+([^ ]+)[ ]*$/
    SUMMARY_DATE   = /^[ ]([^ ]+)[ ]+([^ ]+)[ ]*[\-][ ]*$/
    NEXT_PAGE_LINK = /^[ ]*next [\d]+ postings[ ]*$/

    def initialize(*args)  #:nodoc:
      super(*args)
      
      # Validate that required fields are present:
# TODO:
#      raise ParseError, "Unable to parse Listings: %s" % html.to_html if tags_worth_parsing.length > 0 and  @posts.length == 0
    end

    # Array, PostSummary objects found in the listing
    def posts
      unless @posts
        current_date = nil
        @posts = []
  
        post_tags = html.get_elements_by_tag_name('p','h4')
        
        # The last p in the list is sometimes a 'next XXX pages' link. We don't want to include this in our PostSummary output:
        post_tags.pop if (
          post_tags.length > 0 and 
          post_tags.last.at('a') and 
          NEXT_PAGE_LINK.match post_tags.last.at('a').inner_html
        )
        
        # Now we iterate though the listings:
        post_tags.each do |el|
          case el.name
            when 'p'
             post_summary = self.class.parse_summary(el, current_date)
             post_summary[:url] = '%s://%s%s' % [uri.scheme, uri.host, post_summary[:href]] if uri and post_summary[:href]
             
             @posts << CraigScrape::PostSummary.new(post_summary)
            when 'h4'
              current_date = CraigScrape.most_recently_expired_time $1, $2 if HEADER_DATE.match he_decode(el.inner_html)
          end        
        end        
      end

      @posts
    end

    # String, URL Path of the next page link
    def next_page_href
      unless @next_page_href
        cursor = html.at 'p:last-of-type'
        
        cursor = cursor.at 'a' if cursor
        
        # Category Listings have their 'next 100 postings' link at the end of the doc in a p tag 
        next_link = cursor if cursor and NEXT_PAGE_LINK.match cursor.inner_html

        # Search listings put their next page in a link towards the top
        next_link = (html / 'a').find{ |a| he_decode(a.inner_html) == '<b>Next>></b>' } unless next_link
        
        # This will find the link on 'search listing' pages (if there is one):
        @next_page_href = next_link[:href] if next_link
      end
      
      @next_page_href
    end
    
    # Takes a paragraph element and returns a mostly-parsed Posting
    # We separate this from the rest of the parsing both for readability and ease of testing
    def self.parse_summary(p_element, date = nil)  #:nodoc:
      ret = {}
      
      title_anchor, section_anchor  = p_element.search 'a'
      location_tag = p_element.at 'font'
      has_pic_tag = p_element.at 'span'
      
      href = nil
      
      location = he_decode p_element.at('font').inner_html if location_tag
      ret[:location] = $1 if location and LOCATION.match location
  
      ret[:img_types] = []
      if has_pic_tag
        img_type = he_decode has_pic_tag.inner_html
        img_type = $1.tr('^a-zA-Z0-9',' ') if IMG_TYPE.match img_type
  
        ret[:img_types] = img_type.split(' ').collect{|t| t.to_sym}
      end
  
      ret[:section] = he_decode section_anchor.inner_html if section_anchor
      
      ret[:date] = date
      if SUMMARY_DATE.match he_decode(p_element.children[0])
        ret[:date] = CraigScrape.most_recently_expired_time $1, $2.to_i
      end
  
      if title_anchor
        label = he_decode title_anchor.inner_html
        ret[:label] = $1 if LABEL.match label
    
        ret[:href] = title_anchor[:href]
      end

      # Validate that required fields are present:
# TODO: Move this somewhere
#      raise ParseError, "Unable to parse PostSummary: %s" % p_element.to_html if [@label,@href].any?{|f| f.nil? or f.length == 0}
      
      ret
    end
    
  end
  
  # PostSummary represents a parsed summary posting, typically found on a Listing page.
  # This object is returned by the CraigScrape.scrape_listing methods
  class PostSummary < Scraper
   
    # Time, date of post, as a Time object. Does not include hours/minutes
    attr_reader :date
    
    # String, The label of the post
    attr_reader :label
    
    # String, The path fragment of the post's URI
    attr_reader :href
    
    # String, The location of the post
    attr_reader :location
    
    # String, The abbreviated section of the post
    attr_reader :section
    
    # Array, which image types are listed for the post
    attr_reader :img_types
    
    PRICE    = /((?:^\$[\d]+(?:\.[\d]{2})?)|(?:\$[\d]+(?:\.[\d]{2})?$))/
      
    # true if post summary has the img label
    def has_img?
      img_types.include? :img
    end

    # true if post summary has the pic label
    def has_pic?
      img_types.include? :pic
    end

    # true if post summary has either the img or pic label
    def has_pic_or_img?
      img_types.length > 0
    end
    
    # Returns the best-guess of a price, judging by the label's contents.
    def price
      $1.tr('$','').to_f if @label and PRICE.match(@label)
    end
    
    # Requests and returns the PostFull object that corresponds with this summary's full_url
    def full_post
      @full_post ||= CraigScrape.scrape_full_post full_url if full_url
      
      @full_post
    end
  end

  # Scrapes a single listing url and returns a Listings object representing the contents
  def self.scrape_listing(listing_url)
    #TODO    
    current_uri = ( listing_url.class == String ) ? URI.parse(listing_url) : listing_url 
    
    uri_contents = self.fetch_url(current_uri)
    
    CraigScrape::Listings.new Hpricot.parse(uri_contents), '%s://%s' % [current_uri.scheme, current_uri.host]
    
    rescue ParseError
      puts "Encountered error here! : #{uri_contents.inspect}"
      exit
  end

  # Continually scrapes listings, using the supplied url as a starting point, until the supplied block returns true or
  # until there's no more 'next page' links available to click on
  def self.scrape_until(listing_url, &post_condition)
    ret = []
    
    current_uri = URI.parse listing_url
    catch "ScrapeBreak" do
      while current_uri do 
        listings = scrape_listing current_uri
        
        listings.posts.each do |post|
          throw "ScrapeBreak" if post_condition.call(post)
          ret << post
        end

        current_uri = (listings.next_page_href) ? self.uri_from_href( current_uri, listings.next_page_href ) : nil
      end
    end

    ret
  end

  # Scrapes a single Post Url, and returns a PostFull object representing its contents.
  def self.scrape_full_post(post_url)
    #TODO
    CraigScrape::PostFull.new Hpricot.parse(self.fetch_url(post_url))
  end

  # Continually scrapes listings, using the supplied url as a starting point, until 'count' summaries have been retrieved
  # or no more 'next page' links are avialable to be clicked on. Returns an array of PostSummary objects.
  def self.scrape_posts(listing_url, count)
    count_so_far = 0
    self.scrape_until(listing_url) {|post| count_so_far+=1; count < count_so_far }
  end
  
  # Continually scrapes listings, until the date newer_then has been reached, or no more 'next page' links are avialable to be clicked on.
  # Returns an array of PostSummary objects. Dates are based on the Month/Day 'datestamps' reported in the listing summaries. 
  # As such, time-based cutoffs are not supported here. The scrape_until method, utilizing the SummaryPost.full_post method could achieve
  # time-based cutoffs, at the expense of retrieving every post in full during enumerations.
  #
  # <b>Note:<b> The results will not include post summaries having the newer_then date themselves.
  def self.scrape_posts_since(listing_url, newer_then)
    self.scrape_until(listing_url) {|post| post.date <= newer_then}
  end

end