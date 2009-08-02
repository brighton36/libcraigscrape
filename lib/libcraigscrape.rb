# = About libcraigscrape.rb
#
# All of libcraigscrape's objects and methods are loaded when you use <tt>require 'libcraigscrape'</tt> in your code.
#

# A base class encapsulating the libcraigscrape objects, and providing some utility methods.
class CraigScrape; end

require 'listings'
require 'posting'
require 'geo_listings'

class CraigScrape
  cattr_accessor :time_now
  
  # The only reason I took this out is b/c I might want to make it a cattr_accessor and test with a file:// 
  # prefix.
  SITE_TO_URL_PREFIX = 'http://'
  
  # Takes a variable number of site/path specifiers (strings) as an argument. 
  # This list gets flattened and passed to CraigScrape::GeoListings.find_sites
  # see that method's rdoc for a complete set of rules on what's allowed here.
  def initialize(*args)
    @sites_specs = args.flatten
  end

  # Returns which sites are included in any operations performed by this object. This is directly
  # ascertained from the initial constructor's spec-list
  def sites
    @sites ||= GeoListings.find_sites @sites_specs    
    @sites
  end
  
  # TODO: what exactly is this rdoc going to be...? Maybe rename this to create_post_enumerator
  def each_listing(*fragments)
    listing_urls_for(fragments).each do |url|
      listing = Listings.new url
      yield listing
    end
  end
  
  # TODO: Rdoc? and test!
  def listings(*fragments)
    catch :scrape_break do
      listing_urls_for(fragments).collect do |url| 
        listing = Listings.new url
        throw :scrape_break if yield listing
        listing
      end
    end
  end
  
  # TODO: 
  def each_post(*fragments)
    
  end
  
  # TODO: this actually replaces scrape_until
  def posts(*fragments)
    
  end
  
  # TODO:   
  def posts_since(listing, newer_then)
    
  end
  
  private
  
  def listing_urls_for(listing_fragments)
    listing_fragments.collect{ |lf|
      # This removes any /'s from he beginning of the fragment
      lf = $1 if /^\/(.*)/.match lf
      # This adds a '/' to the end of a path, so long as its not a query we're dealing with...
      lf += '/' unless lf.index '?'
      sites.collect { |site| '%s%s/%s' % [SITE_TO_URL_PREFIX,site,lf] }
    }.flatten
  end

####################### TODO: Deprecate? :

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
    
    listings = CraigScrape::Listings.new listing_url
    catch "ScrapeBreak" do
      while listings do 
        listings.posts.each do |post|
          throw "ScrapeBreak" if post_condition.call(post)
          ret << post
        end

        listings = listings.next_page
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

end