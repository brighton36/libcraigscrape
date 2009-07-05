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

# A base class encapsulating the libcraigscrape objects, and providing some utility methods.
class CraigScrape
  cattr_accessor :time_now

  # Scrapes a single listing url and returns a Listings object representing the contents. 
  # Mostly here to preserve backwards-compatibility with the older api, CraigScrape::Listings.new "listing_url" does the same thing
  # Consider this method 'marked for deprecation'
  def self.scrape_listing(listing_url)    
    CraigScrape::Listings.new listing_url
  end

  # Continually scrapes listings, using the supplied url as a starting point, until the supplied block returns true or
  # until there's no more 'next page' links available to click on
  def self.scrape_until(listing_url, &post_condition)
    ret = []
    
    current_url = listing_url
    catch "ScrapeBreak" do
      while current_url do 
        listings = CraigScrape::Listings.new current_url
        
        listings.posts.each do |post|
          throw "ScrapeBreak" if post_condition.call(post)
          ret << post
        end

        current_url = listings.next_page_url
      end
    end

    ret
  end

  # Scrapes a single Post Url, and returns a Posting object representing its contents.
  # Mostly here to preserve backwards-compatibility with the older api, CraigScrape::Listings.new "listing_url" does the same thing
  # Consider this method 'marked for deprecation'
  def self.scrape_full_post(post_url)
    CraigScrape::Posting.new post_url
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
    self.scrape_until(listing_url) {|post| post.post_date <= newer_then}
  end
    
  # Returns the most recentlt expired  time for the provided month and day
  def self.most_recently_expired_time(month, day)  #:nodoc:
    now = (time_now) ? time_now : Time.now
    
    # This ensures we always generate a time in the past, by guessing the year and subtracting one if we guessed wrong
    ret = Time.local now.year, month, day
    ret = Time.local now.year-1, month, day if ret > now 
    
    ret
  end

  # Scraper is a general-pupose base class for all libcraigscrape Objects. Scraper facilitates all http-related 
  # functionality, and adds some useful helpers for dealing with eager-loading of http-objects and general html
  # methods. It also contains the http-related cattr_accessors:
  # 
  # *logger* - a Logger object to debug http notices too. Defaults to nil
  #
  # *retries_on_fetch_fail* - The number of times to retry a failed uri download. Defaults to 4
  #
  # *sleep_between_fetch_retries* - The amount of seconds to sleep, between successive attempts in the case of a failed download. Defaults to 15.
  class Scraper
    cattr_accessor :logger
    cattr_accessor :sleep_between_fetch_retries
    cattr_accessor :retries_on_fetch_fail

    URL_PARTS = /^(?:([^\:]+)\:\/\/([^\/]*))?(.*)$/
    HTML_TAG  = /<\/?[^>]*>/
    
    # Returns the full url that corresponds to this resource
    attr_reader :url

    # Set some defaults:
    self.retries_on_fetch_fail = 4
    self.sleep_between_fetch_retries = 15
  
    class BadConstructionError < StandardError #:nodoc:
    end
  
    class ParseError < StandardError #:nodoc:
    end
  
    class BadUrlError < StandardError #:nodoc:
    end
  
    class FetchError < StandardError #:nodoc:
    end
    
    # Scraper Objects can be created from either a full URL (string), or a Hash.
    # Currently, this initializer isn't intended to be called from libcraigslist API users, though
    # if you know what you're doing - feel free to try this out.
    #
    # A (string) url can be passed in a 'http://' scheme or a 'file://' scheme.
    #
    # When constructing from a hash, the keys in the hash will be used to set the object's corresponding values.
    # This is useful to create an object without actually making an html request, this is used to set-up an
    # object before it eager-loads any values not already passed in by the constructor hash. Though optional, if
    # you're going to be setting this object up for eager-loadnig, be sure to pass in a :url key in your hash,
    # Otherwise this will fail to eager load.
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
    
    # Indicates whether the resource has yet been retrieved from its associated url.
    # This is useful to distinguish whether the instance was instantiated for the purpose of an eager-load,
    # but hasn't yet been fetched.
    def downloaded?; !@html.nil?; end

    # A URI object corresponding to this Scraped URL
    def uri
      @uri ||= URI.parse @url if @url
      @uri
    end

    private
    
    # Returns text with all html tags removed.
    def strip_html(str)
      str.gsub HTML_TAG, "" if str
    end
    
    # Easy way to fail noisily:
    def parse_error!; raise ParseError, "Error while parsing %s:\n %s" % [self.class.to_s, html]; end
    
    # Returns text with all html entities converted to respective ascii character.
    def he_decode(text); self.class.he_decode text; end

    # Returns text with all html entities converted to respective ascii character.
    def self.he_decode(text); HTMLEntities.new.decode text; end
    
    # Derives a full url, using the current object's url and the provided href
    def url_from_href(href) #:nodoc:
      scheme, host, path = $1, $2, $3 if URL_PARTS.match href

      scheme = uri.scheme if scheme.nil? or scheme.empty? and uri.respond_to? :scheme

      host = uri.host if host.nil? or host.empty? and uri.respond_to? :host

      path = (
        (/\/$/.match(uri.path)) ?
          '%s%s'  % [uri.path,path] :
          '%s/%s' % [File.dirname(uri.path),path]
      ) unless /^\//.match path

      '%s://%s%s' % [scheme, host, path]
    end
    
    def fetch_uri(uri)
  
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
              
              fetch_uri URI.parse(url_from_href(redirect_to))
            else
              # Sometimes Craigslist seems to return 404's for no good reason, and a subsequent fetch will give you what you want
              error_description = 'Unable to fetch "%s" (%s)' % [ @url, resp.response.code ]
      
              logger.info error_description if logger
              
              raise FetchError, error_description
            end
          rescue FetchError,Timeout::Error,Errno::ECONNRESET => err
            logger.info 'Timeout error while requesting "%s"' % @url if logger and err.class == Timeout::Error
            logger.info 'Connection reset while requesting "%s"' % @url if logger and err.class == Errno::ECONNRESET
            
            fetch_attempts += 1

            if fetch_attempts <= self.retries_on_fetch_fail
              sleep self.sleep_between_fetch_retries if self.sleep_between_fetch_retries
              logger.info 'Retrying fetch ....' if logger
              retry
            else
              raise err
            end
          end
        else
          raise BadUrlError, "Unknown URI scheme for the url: #{@url}"
      end
    end
    
    def html
      @html ||= Hpricot.parse fetch_uri(uri) if uri
      @html
    end
  end

  # Posting represents a fully downloaded, and parsed, Craigslist post.
  # This class is generally returned by the listing scrape methods, and 
  # contains the post summaries for a specific search url, or a general listing category 
  class Posting < Scraper
    
    POST_DATE       = /Date:[^\d]*((?:[\d]{2}|[\d]{4})\-[\d]{1,2}\-[\d]{1,2}[^\d]+[\d]{1,2}\:[\d]{1,2}[ ]*[AP]M[^a-z]+[a-z]+)/i
    LOCATION        = /Location\:[ ]+(.+)/
    HEADER_LOCATION = /^.+[ ]*\-[ ]*[\$]?[\d]+[ ]*\((.+)\)$/
    POSTING_ID      = /PostingID\:[ ]+([\d]+)/
    REPLY_TO        = /(.+)/
    PRICE           = /((?:^\$[\d]+(?:\.[\d]{2})?)|(?:\$[\d]+(?:\.[\d]{2})?$))/
    USERBODY_PARTS  = /\<div id\=\"userbody\">(.+)\<br[ ]*[\/]?\>\<br[ ]*[\/]?\>(.+)\<\/div\>/m
    IMAGE_SRC       = /\<im[a]?g[e]?[^\>]*src=(?:\'([^\']+)\'|\"([^\"]+)\"|([^ ]+))[^\>]*\>/

    # This is really just for testing, in production use, uri.path is a better solution
    attr_reader :href #:nodoc:

    # Create a new Post via a url (String), or supplied parameters (Hash)
    def initialize(*args)
      super(*args)

      # Validate that required fields are present, at least - if we've downloaded it from a url
      parse_error! if args.first.kind_of? String and !flagged_for_removal? and !deleted_by_author? and [
        contents,posting_id,post_time,header,title,full_section
      ].any?{|f| f.nil? or (f.respond_to? :length and f.length == 0)}
    end
        

    # String, The contents of the item's html body heading
    def header
      unless @header
        h2 = html.at 'h2' if html
        @header = he_decode h2.inner_html if h2
      end
      
      @header
    end
    
    # String, the item's title
    def title
      unless @title
        title_tag = html.at 'title' if html
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
        end if html
      end

      @full_section
    end

    # String, represents the post's reply-to address, if listed
    def reply_to
      unless @reply_to
        cursor = html.at 'hr' if html
        cursor = cursor.next_sibling until cursor.nil? or cursor.name == 'a'
        @reply_to = $1 if cursor and REPLY_TO.match he_decode(cursor.inner_html)
      end
      
      @reply_to
    end
    
    # Time, reflects the full timestamp of the posting 
    def post_time
      unless @post_time
        cursor = html.at 'hr' if html
        cursor = cursor.next_node until cursor.nil? or POST_DATE.match cursor.to_s
        @post_time = Time.parse $1 if $1
      end
      
      @post_time
    end

    # Integer, Craigslist's unique posting id
    def posting_id
      unless @posting_id
        cursor = (html/"#userbody").first if html
        cursor = cursor.next_node until cursor.nil? or POSTING_ID.match cursor.to_s
        @posting_id = $1.to_i if $1
      end
    
      @posting_id
    end
    
    # String, The full-html contents of the post
    def contents
      unless @contents
        @contents = user_body if html
        @contents = he_decode @contents.strip if @contents
      end
      
      @contents
    end
    
    # String, the location of the item, as best could be parsed
    def location
      if @location.nil? and craigslist_body and html
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
        
        # So, *sometimes* the location just ends up being in the header, I don't know why:
        @location = $1 if @location.nil? and HEADER_LOCATION.match header
      end
      
      @location
    end

    # Array, urls of the post's images that are *not* hosted on craigslist
    def images
      # Keep in mind that when users post html to craigslist, they're often not posting wonderful html...
      @images = ( 
        contents ? 
          contents.scan(IMAGE_SRC).collect{ |a| a.find{|b| !b.nil? } } :
          [] 
      ) unless @images
      
      @images
    end

    # Array, urls of the post's craigslist-hosted images
    def pics
      unless @pics
        @pics = []
        
        if html and craigslist_body
          # Now let's find the craigslist hosted images:
          img_table = (craigslist_body / 'table').find{|e| e.name == 'table' and e[:summary] == 'craigslist hosted images'}
        
          @pics = (img_table / 'img').collect{|i| i[:src]} if img_table
        end
      end
      
      @pics
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
      
      @deleted_by_author
    end
    
    
    # Reflects only the date portion of the posting. Does not include hours/minutes. This is useful when reflecting the listing scrapes, and can be safely
    # used if you wish conserve bandwidth by not pulling an entire post from a listing scrape.
    def post_date
      @post_date = Time.local(*[0]*3+post_time.to_a[3...10]) unless @post_date or post_time.nil?
      
      @post_date
    end
    
    # Returns The post label. The label would appear at first glance to be indentical to the header - but its not. 
    # The label is cited on the listings pages, and generally includes everything in the header - with the exception of the location.
    # Sometimes there's additional information ie. '(map)' on rea listings included in the header, that aren't to be listed in the label
    # This is also used as a bandwidth shortcut for the craigwatch program, and is a guaranteed identifier for the post, that won't result
    # in a full page load from the post's url.
    def label
      unless @label or system_post?
        @label = header
        
        @label = $1 if location and /(.+?)[ ]*\(#{location}\).*?$/.match @label
      end
      
      @label
    end

    # Array, which image types are listed for the post.
    # This is always able to be pulled from the listing post-summary, and should never cause an additional page load
    def img_types
      unless @img_types
        @img_types = []
        
        @img_types << :img if images.length > 0
        @img_types << :pic if pics.length > 0
      end
      
      @img_types
    end
    
    # Retrieves the most-relevant craigslist 'section' of the post. This is *generally* the same as full_section.last. However, 
    # this (sometimes/rarely) conserves bandwidth by pulling this field from the listing post-summary
    def section
      unless @section
        @section = full_section.last if full_section  
      end
      
      @section
    end

    # true if post summary has 'img(s)'. 'imgs' are different then pics, in that the resource is *not* hosted on craigslist's server. 
    # This is always able to be pulled from the listing post-summary, and should never cause an additional page load
    def has_img?
      img_types.include? :img
    end

    # true if post summary has 'pic(s)'. 'pics' are different then imgs, in that craigslist is hosting the resource on craigslist's servers
    # This is always able to be pulled from the listing post-summary, and should never cause an additional page load
    def has_pic?
      img_types.include? :pic
    end

    # true if post summary has either the img or pic label
    # This is always able to be pulled from the listing post-summary, and should never cause an additional page load
    def has_pic_or_img?
      img_types.length > 0
    end

    # Returns the best-guess of a price, judging by the label's contents. Price is available when pulled from the listing summary
    # and can be safely used if you wish conserve bandwidth by not pulling an entire post from a listing scrape.
    def price
      $1.tr('$','').to_f if label and PRICE.match label
    end
    
    # Returns the post contents with all html tags removed
    def contents_as_plain
      strip_html contents
    end

    # Returns the header with all html tags removed. Granted, the header should usually be plain, but in the case of a 
    # 'system_post' we may get tags in here
    def header_as_plain
      strip_html header
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
             post_summary = self.class.parse_summary el, current_date
             
             # Validate that required fields are present:
             parse_error! unless [post_summary[:label],post_summary[:href]].all?{|f| f and f.length > 0}
      
             post_summary[:url] = url_from_href post_summary[:href]

             @posts << CraigScrape::Posting.new(post_summary)
           when 'h4'
            # Let's make sense of the h4 tag, and then read all the p tags below it
            if HEADER_DATE.match he_decode(el.inner_html)
              # Generally, the H4 tags contain valid dates. When they do - this is easy:
              current_date = CraigScrape.most_recently_expired_time $1, $2
            elsif html.at('h4:last-of-type') == el
              # There's a specific bug, where these nonsense h4's just appear without anything relevant inside them.
              # They're safe to ignore if they're not the last h4 on the page. I fthey're the last h4 on the page, 
              # we need to pull up the full post in order to accurate tell the date.
              # Setting this to nil will achieve the eager-load.
              current_date = nil
            end
          end        
        end        
      end

      @posts
    end

    # String, URL Path href-fragment of the next page link
    def next_page_href
      unless @next_page_href
        cursor = html.at 'p:last-of-type'
        
        cursor = cursor.at 'a' if cursor
        
        # Category Listings have their 'next 100 postings' link at the end of the doc in a p tag 
        next_link = cursor if cursor and NEXT_PAGE_LINK.match cursor.inner_html

        # Search listings put their next page in a link towards the top
        next_link = (html / 'a').find{ |a| he_decode(a.inner_html) == '<b>Next>></b>' } unless next_link
                
        # Some search pages have a bug, whereby a 'next page' link isn't displayed,
        # even though we can see that theres another page listed in the page-number links block at the top
        # and bottom of the listing page
        unless next_link
          cursor = html % 'div.sh:first-of-type > b:last-of-type'

          # If there's no 'a' in the next sibling, we'll have just performed a nil assignment, otherwise
          # We're looking good.
          next_link = cursor.next_sibling if cursor and /^[\d]+$/.match cursor.inner_html
        end
        
        # We have an anchor tag - so - let's assign the href:
        @next_page_href = next_link[:href] if next_link
      end
      
      @next_page_href
    end
    
    # String, Full URL Path of the 'next page' link
    def next_page_url
      (next_page_href) ? url_from_href(next_page_href) : nil
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
  
      ret[:section] = he_decode(section_anchor.inner_html).split("\302\240").join(" ") if section_anchor
      
      ret[:post_date] = date
      if SUMMARY_DATE.match he_decode(p_element.children[0])
        ret[:post_date] = CraigScrape.most_recently_expired_time $1, $2.to_i
      end
  
      if title_anchor
        label = he_decode title_anchor.inner_html
        ret[:label] = $1 if LABEL.match label
    
        ret[:href] = title_anchor[:href]
      end
      
      ret
    end
  end
  
  # GeoListings represents a parsed Craigslist geo lisiting page. (i.e. {'http://geo.craigslist.org/iso/us'}[http://geo.craigslist.org/iso/us]) 
  # These list all the craigslist sites in a given region.
  class GeoListings < Scraper
    LOCATION_NAME = /[ ]*\>[ ](.+)[ ]*/
    GEOLISTING_BASE_URL = %{http://geo.craigslist.org/iso/}

    # The geolisting constructor works like all other Scraper objects, in that it accepts a string 'url'. 
    # In addition though, here we'll accept an array like %w(us fl) which gets converted to
    # {'http://geo.craigslist.org/iso/us/fl'}[http://geo.craigslist.org/iso/us/fl]
    def initialize(init_via = nil)
      super init_via.kind_of?(Array) ? "#{GEOLISTING_BASE_URL}#{init_via.join '/'}" : init_via
      
      # Validate that required fields are present, at least - if we've downloaded it from a url
      parse_error! unless location
    end

    # Returns the GeoLocation's full name
    def location
      unless @name
        cursor = html % 'h3 > b > a:first-of-type'
        cursor = cursor.next_node if cursor       
        @name = $1 if cursor and LOCATION_NAME.match he_decode(cursor.to_s)
      end
      
      @name
    end

    # Returns a hash of site name to urls in the current listing
    def sites
      unless @sites
        @sites = {}
        (html / 'div#list > a').each do |el_a|
          site_name = he_decode strip_html(el_a.inner_html)
          @sites[site_name] = el_a[:href]
        end
      end
      
      @sites
    end
  end

end