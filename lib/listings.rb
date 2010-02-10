# = About listings.rb
#
# This file contains the parsing code, and logic relating to post-listing pages. You
# should never need to include this file directly, as all of libcraigscrape's objects and methods 
# are loaded when you use <tt>require 'libcraigscrape'</tt> in your code.
#

require 'scraper'

# Listings represents a parsed Craigslist listing page and is generally returned by CraigScrape.scrape_listing
class CraigScrape::Listings < CraigScrape::Scraper
  LABEL          = /^(.+?)[ ]*[\-]?$/
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
  
  # Returns a Listings object of the next_page_url on the current listings object
  def next_page
    CraigScrape::Listings.new next_page_url if next_page_url
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