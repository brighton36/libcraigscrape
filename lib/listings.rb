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
  HEADER_DATE    = /^[ ]*(?:Sun|Mon|Tue|Wed|Thu|Fri|Sat)[ ]+(Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Nov|Dec)[ ]+([0-9]{1,2})[ ]*$/i
  SUMMARY_DATE   = /^[ ]([^ ]+)[ ]+([^ ]+)[ ]*[\-][ ]*$/
  NEXT_PAGE_LINK = /^[ ]*(?:next [\d]+ postings|Next \>\>)[ ]*$/

  XPATH_POST_DATE = "*[@class='itemdate']"
  XPATH_POST_IMGPIC = "*[@class='itempx']/*[@class='p']"
  XPATH_POST_PRICE = "*[@class='itempp']"
  XPATH_PAGENAV_LINKS = "//*[@class='ban']//a"

  # Array, PostSummary objects found in the listing
  def posts
    unless @posts
      current_date = nil
      @posts = []

      # All we care about are p and h4 tags. This seemed to be the only way I could do this on Nokogiri:
      post_tags = html.search('*').reject{|n| !/^(?:p|h4)$/i.match n.name } 

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
           post_summary = parse_summary el, current_date

           # Validate that required fields are present:
           parse_error! unless [post_summary[:label],post_summary[:href]].all?{|f| f and f.length > 0}
    
           post_summary[:url] = url_from_href post_summary[:href]

           @posts << CraigScrape::Posting.new(post_summary)
         when 'h4'
          # Let's make sense of the h4 tag, and then read all the p tags below it
          if HEADER_DATE.match he_decode(el.inner_html)
            # Generally, the H4 tags contain valid dates. When they do - this is easy:
            current_date = Date.parse [$1, $2].join('/')
          elsif html.at('h4:last-of-type') == el
            # There's a specific bug in craigslist, where these nonsense h4's just appear without anything relevant inside them.
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
     
      if html.at_xpath(XPATH_PAGENAV_LINKS)
        # Post 12/3
        next_link = html.xpath(XPATH_PAGENAV_LINKS).find{|link| NEXT_PAGE_LINK.match link.content}
        @next_page_href = next_link[:href] if next_link
      else 
        # Old style
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
          next_link = cursor.next_element if cursor and /^[\d]+$/.match cursor.inner_html
        end
        
        # We have an anchor tag - so - let's assign the href:
        @next_page_href = next_link[:href] if next_link
      end
    end
    
    @next_page_href
  end
  
  # String, Full URL Path of the 'next page' link
  def next_page_url
    (next_page_href) ? url_from_href(next_page_href) : nil
  end
  
  # Returns a Listings object of the next_page_url on the current listings object
  def next_page
    CraigScrape::Listings.new URI.encode(next_page_url) if next_page_url
  end
 
  private

  # Takes a paragraph element and returns a mostly-parsed Posting
  # We separate this from the rest of the parsing both for readability and ease of testing
  def parse_summary(p_element, date = nil)  #:nodoc:
    ret = {}

    title_anchor   = nil
    section_anchor = nil

    # This loop got a little more complicated after Craigslist start inserting weird <spans>'s in 
    # its list summary postings (See test_new_listing_span051710) 
    p_element.search('a').each do |a_el|
      # We want the first a-tag that doesn't have spans in it to be the title anchor
      if title_anchor.nil?
        title_anchor = a_el if !a_el.at('span')
      # We want the next a-tag after the title_anchor to be the section anchor
      elsif section_anchor.nil?
        section_anchor = a_el
        # We have no need to tranverse these further:
        break
      end
    end
    
    location_tag = p_element.at 'font'
    
    href = nil
    
    location = he_decode p_element.at('font').inner_html if location_tag
    ret[:location] = $1 if location and LOCATION.match location

    if p_element.at_xpath XPATH_POST_PRICE
      price = p_element.at_xpath(XPATH_POST_PRICE).content.tr('^0-9', '')
      ret[:price] = Money.new price.to_i*100, 'USD' unless price.empty?
    end

    ret[:img_types] = []
    if p_element.at_xpath XPATH_POST_IMGPIC
      # Post 12/3
      ret[:img_types] = p_element.at_xpath(XPATH_POST_IMGPIC).content.scan(/\w+/).collect(&:to_sym)
    else
      # Old style:
      has_pic_tag = p_element.at 'span'
      if has_pic_tag
        img_type = he_decode has_pic_tag.inner_html
        img_type = $1.tr('^a-zA-Z0-9',' ') if IMG_TYPE.match img_type

        ret[:img_types] = img_type.split(' ').collect{|t| t.to_sym}
      end
    end

    ret[:section] = he_decode(section_anchor.inner_html) if section_anchor
   
    ret[:post_date] = date
    if p_element.at_xpath(XPATH_POST_DATE)
      # Post 12/3
      if /\A([^ ]+) ([\d]+)\Z/.match p_element.at_xpath(XPATH_POST_DATE).content.strip
        ret[:post_date] = Date.parse [$1, $2].join('/')
      end
    elsif SUMMARY_DATE.match he_decode(p_element.children[0])
      # Old style
        ret[:post_date] = Date.parse [$1, $2].join('/')
    end

    if title_anchor
      label = he_decode title_anchor.inner_html
      ret[:label] = $1 if LABEL.match label
  
      ret[:href] = title_anchor[:href]
    end
    
    ret
  end

end
