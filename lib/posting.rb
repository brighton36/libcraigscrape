# = About posting.rb
#
# This file contains the parsing code, and logic relating to craiglist postings. You
# should never need to include this file directly, as all of libcraigscrape's objects and methods 
# are loaded when you use <tt>require 'libcraigscrape'</tt> in your code.
#

require 'scraper'

# Posting represents a fully downloaded, and parsed, Craigslist post.
# This class is generally returned by the listing scrape methods, and 
# contains the post summaries for a specific search url, or a general listing category 
class CraigScrape::Posting < CraigScrape::Scraper
  
  POST_DATE       = /Date:[^\d]*((?:[\d]{2}|[\d]{4})\-[\d]{1,2}\-[\d]{1,2}[^\d]+[\d]{1,2}\:[\d]{1,2}[ ]*[AP]M[^a-z]+[a-z]+)/i
  LOCATION        = /Location\:[ ]+(.+)/
  HEADER_LOCATION = /\((.+)\)$/
  POSTING_ID      = /Posting[ ]?ID\:[ ]*([\d]+)/
  REPLY_TO        = /(.+)/
  PRICE           = /((?:^\$[\d]+(?:\.[\d]{2})?)|(?:\$[\d]+(?:\.[\d]{2})?$))/
   
  # NOTE: we implement the (?:) to first check the 'old' style format, and then the 'new style'
  # (As of 12/03's parse changes)
  USERBODY_PARTS  = /^(.+)\<div id\=\"userbody\">(.+)\<br[ ]*[\/]?\>\<br[ ]*[\/]?\>(.+)\<\/div\>(.+)$/m
  HTML_HEADER     = /^(.+)\<div id\=\"userbody\">/m
  IMAGE_SRC       = /\<im[a]?g[e]?[^\>]*src=(?:\'([^\']+)\'|\"([^\"]+)\"|([^ ]+))[^\>]*\>/

  # This is used to determine if there's a parse error
  REQUIRED_FIELDS = %w(contents posting_id post_time header title full_section)

  XPATH_USERBODY = "//*[@id='userbody']"
  XPATH_POSTINGBODY = "//*[@id='postingbody']"
  
  XPATH_BLURBS = "//ul[@class='blurbs']"
  XPATH_PICS = ["//*[@class='tn']/a/@href",
    # For some posts (the newest ones on 01/20/12) we find the images:
    "//*[@id='thumbs']/a/@href"
    ].join('|')
  XPATH_REPLY_TO = ["//*[@class='dateReplyBar']/small/a",
    # For some posts (the newest ones on 01/20/12) we find the reply to this way:
    "//*[@class='dateReplyBar']/*[@id='replytext']/following-sibling::a" 
    ].join('|')
  XPATH_POSTINGBLOCK = "//*[@class='postingidtext' or @class='postinginfos']"
  XPATH_POSTED_DATE = "//*[@class='postinginfos']/*[@class='postinginfo']/date"

  # This is really just for testing, in production use, uri.path is a better solution
  attr_reader :href #:nodoc:

  # Create a new Post via a url (String), or supplied parameters (Hash)
  def initialize(*args)
    super(*args)

    # Validate that required fields are present, at least - if we've downloaded it from a url
    if args.first.kind_of? String and is_active_post?
      unparsed_fields = REQUIRED_FIELDS.find_all{|f| 
        val = send(f)
        val.nil? or (val.respond_to? :length and val.length == 0)
      } 
      parse_error! unparsed_fields unless unparsed_fields.empty?
    end  

  end


  # String, The contents of the item's html body heading
  def header
    unless @header
      h2 = html_head.at 'h2' if html_head
      @header = he_decode h2.inner_html if h2
    end
    
    @header
  end
  
  # String, the item's title
  def title
    unless @title
      title_tag = html_head.at 'title' if html_head
      @title = he_decode title_tag.inner_html if title_tag
      @title = nil if @title and @title.length == 0
    end
  
    @title
  end

  # Array, hierarchial representation of the posts section
  def full_section
    unless @full_section
      @full_section = []
      
      (html_head / "*[@class='bchead']//a").each do |a|
        @full_section << he_decode(a.inner_html) unless a['id'] and a['id'] == 'ef'
      end if html_head
      
      # For some posts (the newest ones on 01/20/12) craigslist is pre-pending
      # a silly "CL" to the section. Let's strip that:
      @full_section.delete_at(0) if @full_section[0] == 'CL'
    end

    @full_section
  end

  # String, represents the post's reply-to address, if listed
  def reply_to
    unless @reply_to
      if html.at_xpath(XPATH_REPLY_TO)
        @reply_to = html.at_xpath(XPATH_REPLY_TO).content
      else
        cursor = html_head.at 'hr' if html_head
        cursor = cursor.next until cursor.nil? or cursor.name == 'a'
        @reply_to = $1 if cursor and REPLY_TO.match he_decode(cursor.inner_html)
      end
    end
    
    @reply_to
  end
  
  # Time, reflects the full timestamp of the posting 
  def post_time
    unless @post_time
      if html.at_xpath(XPATH_POSTED_DATE)
        # For some posts (the newest ones on 01/20/12) craigslist made this really 
        # easy for us. 
        @post_time = DateTime.parse(html.at_xpath(XPATH_POSTED_DATE))
      else
        # The bulk of the post time/dates are parsed via a simple regex:
        cursor = html_head.at 'hr' if html_head
        cursor = cursor.next until cursor.nil? or POST_DATE.match cursor.to_s
        @post_time = DateTime.parse($1) if $1
      end
    end
    
    @post_time
  end

  # Integer, Craigslist's unique posting id
  def posting_id
    if @posting_id 

    elsif USERBODY_PARTS.match html_source
      # Old style:
      html_footer = $4
      cursor = Nokogiri::HTML html_footer, nil, HTML_ENCODING 
      cursor = cursor.next until cursor.nil? or 
      @posting_id = $1.to_i if POSTING_ID.match html_footer.to_s
    else
      # Post 12/3
      @posting_id = $1.to_i if POSTING_ID.match html.xpath(XPATH_POSTINGBLOCK).to_s
    end
  
    @posting_id
  end
  
  # String, The full-html contents of the post
  def contents
    unless @contents
      @contents = if html.at_xpath(XPATH_POSTINGBODY)
        # For some posts (the newest ones on 01/20/12) craigslist made this really 
        # easy for us. 
        html.at_xpath(XPATH_POSTINGBODY).children.to_s
      elsif html_source
        # Otherwise we have to parse this in a convoluted way from the userbody
        # section:
        user_body
      end
      
      # This helps clean up the whitespace around the sides, in case we got any: 
      @contents = he_decode(@contents).strip if @contents
    end
    
    @contents
  end
  
  # String, the location of the item, as best could be parsed
  def location
    if @location.nil? and html
     
      if html.at_xpath(XPATH_BLURBS)
        # This is the post-12/3/12 style:

        # Sometimes the Location is in the body :
        @location = $1 if html.xpath(XPATH_BLURBS).first.children.any?{|c| 
          LOCATION.match c.content}

      elsif craigslist_body
        # Location (when explicitly defined):
        cursor = craigslist_body.at 'ul' unless @location

        # This is the legacy style:
        # Note: Apa section includes other things in the li's (cats/dogs ok fields)
        cursor.children.each do |li|
          if LOCATION.match li.inner_html
            @location = he_decode($1) and break
            break
          end
        end if cursor

        # Real estate listings can work a little different for location:
        unless @location
          cursor = craigslist_body.at 'small'
          cursor = cursor.previous until cursor.nil? or cursor.text?
          
          @location = he_decode(cursor.to_s.strip) if cursor
        end
        
      end
      
      # So, *sometimes* the location just ends up being in the header, I don't know why.
      # This happens on old-style and new-style posts:
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
      
      if html 
        if html.at_xpath(XPATH_PICS)
          @pics = html.xpath(XPATH_PICS).collect(&:value)
        elsif craigslist_body
          # This is the pre-12/3/12 style:
          # Now let's find the craigslist hosted images:
          img_table = (craigslist_body / 'table').find{|e| e.name == 'table' and e[:summary] == 'craigslist hosted images'}
        
          @pics = (img_table / 'img').collect{|i| i[:src]} if img_table
        end
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
  
  # Returns true if this Post was parsed, and represents a 'This posting has expired.' notice
  def posting_has_expired?
    @posting_has_expired = (
      system_post? and header_as_plain == "This posting has expired."
    ) if @posting_has_expired.nil?
    
    @posting_has_expired
  end
  
  # Reflects only the date portion of the posting. Does not include hours/minutes. This is useful when reflecting the listing scrapes, and can be safely
  # used if you wish conserve bandwidth by not pulling an entire post from a listing scrape.
  def post_date
    @post_date = post_time.to_date unless @post_date or post_time.nil?
    
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
    @img_types || [ (images.length > 0) ? :img : nil, 
      (pics.length > 0) ? :pic : nil ].compact
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
    unless @price
      (header and PRICE.match label) ? 
        @price = Money.new($1.tr('$','').to_i*100, 'USD') : nil
    end
    @price
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

  # This is mostly used to determine if the post should be checked for
  # parse errors. Might be useful for someone else though
  def is_active_post?
    [flagged_for_removal?, posting_has_expired?, deleted_by_author?].none?
  end 

  private

  # I set apart from html to work around the SystemStackError bugs in test_bugs_found061710. Essentially we 
  # return everything above the user_body
  def html_head
    @html_head = Nokogiri::HTML  $1, nil, HTML_ENCODING if @html_head.nil? and HTML_HEADER.match html_source
    # We return html itself if HTML_HEADER doesn't match, which would be case for a 404 page or something
    @html_head ||= html
     
    @html_head
  end

  # OK - so the biggest problem parsing the contents of a craigslist post is that users post invalid html all over the place
  # This bad html trips up html parsers, and I've resorted to splitting the page up using string parsing like so:
  # We return this as a string, since it makes sense, and since its tough to say how hpricot might mangle this if the html is whack
  def user_body
    if USERBODY_PARTS.match html_source
      # This is the pre-12/3/12 style:
      $2
    elsif html.at_xpath(XPATH_USERBODY)
      # There's a bunch of junk in here that we don't want, so this loop removes
      # everything after (and including) the last script tag, from the result
      user_body = html.xpath(XPATH_USERBODY)
      hit_delimeter = false
      # Since some posts don't actually have the script tag:
      delimeter = user_body.at_xpath('script') ? :script : :comment
      user_body.first.children.to_a.reverse.reject{ |p|
        if hit_delimeter
          false
        elsif ( (delimeter == :script and p.name == 'script') or 
          (delimeter == :comment and p.comment? and p.content.strip == "START CLTAGS") )
          hit_delimeter = true 
        else
          true
        end
      }.reverse.collect(&:to_s).join
    end
  end
  
  # Read the notes on user_body. However,  unlike the user_body, the craigslist portion of this div can be relied upon to be valid html. 
  # So - we'll return it as a Nokogiri object.
  def craigslist_body
    Nokogiri::HTML $3, nil, HTML_ENCODING if USERBODY_PARTS.match html_source
  end

end
