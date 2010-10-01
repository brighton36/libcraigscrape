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
  HEADER_LOCATION = /^.+[ ]*\-[ ]*[\$]?[\d]+[ ]*\((.+)\)$/
  POSTING_ID      = /PostingID\:[ ]+([\d]+)/
  REPLY_TO        = /(.+)/
  PRICE           = /((?:^\$[\d]+(?:\.[\d]{2})?)|(?:\$[\d]+(?:\.[\d]{2})?$))/
  USERBODY_PARTS  = /^(.+)\<div id\=\"userbody\">(.+)\<br[ ]*[\/]?\>\<br[ ]*[\/]?\>(.+)\<\/div\>(.+)$/m
  HTML_HEADER     = /^(.+)\<div id\=\"userbody\">/m
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
      
      (html_head/"div[@class='bchead']//a").each do |a|
        @full_section << he_decode(a.inner_html) unless a['id'] and a['id'] == 'ef'
      end if html_head
    end

    @full_section
  end

  # String, represents the post's reply-to address, if listed
  def reply_to
    unless @reply_to
      cursor = html_head.at 'hr' if html_head
      cursor = cursor.next_sibling until cursor.nil? or cursor.name == 'a'
      @reply_to = $1 if cursor and REPLY_TO.match he_decode(cursor.inner_html)
    end
    
    @reply_to
  end
  
  # Time, reflects the full timestamp of the posting 
  def post_time
    unless @post_time
      cursor = html_head.at 'hr' if html_head
      cursor = cursor.next_node until cursor.nil? or POST_DATE.match cursor.to_s
      @post_time = Time.parse $1 if $1
    end
    
    @post_time
  end

  # Integer, Craigslist's unique posting id
  def posting_id
    unless @posting_id     
      cursor = Hpricot.parse html_footer if html_footer
      cursor = cursor.next_node until cursor.nil? or POSTING_ID.match cursor.to_s
      @posting_id = $1.to_i if $1
    end
  
    @posting_id
  end
  
  # String, The full-html contents of the post
  def contents
    unless @contents
      @contents = user_body if html_source
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

  # I set apart from html to work around the SystemStackError bugs in test_bugs_found061710. Essentially we 
  # return everything above the user_body
  def html_head
    @html_head = Hpricot.parse $1 if @html_head.nil? and HTML_HEADER.match html_source
    # We return html itself if HTML_HEADER doesn't match, which would be case for a 404 page or something
    @html_head ||= html
     
    @html_head
  end

  # Since we started having so many problems with Hpricot flipping out on whack content bodies, 
  # I added this to return everything south of the user_body
  def html_footer     
    $4 if USERBODY_PARTS.match html_source
  end

  # OK - so the biggest problem parsing the contents of a craigslist post is that users post invalid html all over the place
  # This bad html trips up hpricot, and I've resorted to splitting the page up using string parsing like so:
  # We return this as a string, since it makes sense, and since its tough to say how hpricot might mangle this if the html is whack
  def user_body     
    $2 if USERBODY_PARTS.match html_source
  end
  
  # Read the notes on user_body. However,  unlike the user_body, the craigslist portion of this div can be relied upon to be valid html. 
  # So - we'll return it as an Hpricot object.
  def craigslist_body
    Hpricot.parse $3 if USERBODY_PARTS.match html_source
  end

end