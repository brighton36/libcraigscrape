# = About libcraigscrape.rb
#
# All of libcraigscrape's objects and methods are loaded when you use <tt>require 'libcraigscrape'</tt> in your code.
#
require 'rubygems'

gem 'activesupport', '~> 2.3'
gem 'nokogiri',      '~> 1.4.4'
gem 'htmlentities',  '~> 4.0.0'


require 'net/http'
require 'zlib'
require 'nokogiri'
require 'htmlentities'
require 'active_support'


# A base class encapsulating the various libcraigscrape objects, and providing most of the 
# craigslist interaction methods. Currently, we're supporting the old Class methods 
# in a legacy-compatibility mode, but these methods are marked for deprecation. Instead,
# create an instance of the Craigslist object, and use its Public Instance methods.
# See the README for easy to follow examples.

class CraigScrape
  cattr_accessor :time_now
  cattr_accessor :site_to_url_prefix
  
  #--
  # NOTE:
  # The only reason I took this out is b/c I might want to test with a file:// 
  # prefix at some point
  #++
  self.site_to_url_prefix = 'http://'

  
  # Takes a variable number of site/path specifiers (strings) as an argument. 
  # This list gets flattened and passed to CraigScrape::GeoListings.find_sites .
  # See that method's rdoc for a complete set of rules on what arguments are allowed here.
  def initialize(*args)
    @sites_specs = args.flatten
  end

  # Returns which sites are included in any operations performed by this object. This is directly
  # ascertained from the initial constructor's spec-list
  def sites
    @sites ||= GeoListings.find_sites @sites_specs    
    @sites
  end
  
  # Determines all listings which can be construed by combining the sites specified in the object
  # constructor with the provided url-path fragments. 
  #
  # Passes the <b>first page listing</b> of each of these urls to the provided block.
  def each_listing(*fragments)
    listing_urls_for(fragments).each{|url| yield Listings.new(url) }
  end
  
  # Determines all listings which can be construed by combining the sites specified in the object
  # constructor with the provided url-path fragments. 
  #
  # Passes <b>each page on every listing</b> for the passed URLs to the provided block.
  def each_page_in_each_listing(*fragments)
    each_listing(*fragments) do |listing|
      while listing
        yield listing
        listing = listing.next_page 
      end
    end
  end
  
  # Determines all listings which can be construed by combining the sites specified in the object
  # constructor with the provided url-path fragments. 
  #
  # Returns the <b>first page listing</b> of each of these urls to the provided block.
  def listings(*fragments)
    listing_urls_for(fragments).collect{|url| Listings.new url }
  end
  
  # Determines all listings which can be construed by combining the sites specified in the object
  # constructor with the provided url-path fragments. 
  #
  # Passes all posts from each of these urls to the provided block, in the order they're parsed
  # (for each listing, newest posts are returned first).
  def each_post(*fragments)
    each_page_in_each_listing(*fragments){ |l| l.posts.each{|p| yield p} }
  end
  
  # Determines all listings which can be construed by combining the sites specified in the object
  # constructor with the provided url-path fragments. 
  #
  # Returns all posts from each of these urls, in the order they're parsed
  # (newest posts first).
  def posts(*fragments)
    ret = []
    each_page_in_each_listing(*fragments){ |l| ret += l.posts }
    ret
  end
  
  # Determines all listings which can be construed by combining the sites specified in the object
  # constructor with the provided url-path fragments. 
  #
  # Returns all posts from each of these urls, which are newer than the provider 'newer_then' date.
  # (Returns 'newest' posts first).
  def posts_since(newer_then, *fragments)
    ret = []
    fragments.each do |frag|
      each_post(frag) do |p|
        break if p.post_date <= newer_then
        ret << p
      end
    end

    ret    
  end
  
  class << self # Class methods

    #--
    # NOTE: These Class methods are all marked for deprecation as of
    # version 0.8.0, and should not be used with any new project code
    #++

    # <b>This method is for legacy compatibility and is not recommended for use by new projects.</b>
    # Instead, consider using CraigScrape::Listings.new 
    #
    # Scrapes a single listing url and returns a Listings object representing the contents. 
    # Mostly here to preserve backwards-compatibility with the older api, CraigScrape::Listings.new "listing_url" does the same thing
    def scrape_listing(listing_url)    
      CraigScrape::Listings.new listing_url
    end

    # <b>This method is for legacy compatibility and is not recommended for use by new projects.</b>
    # Instead, consider using the CraigScrape::each_post method.
    #
    # Continually scrapes listings, using the supplied url as a starting point, until the supplied block returns true or
    # until there's no more 'next page' links available to click on
    def scrape_until(listing_url, &post_condition)
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

    # <b>This method is for legacy compatibility and is not recommended for use by new projects.</b>
    # Instead, consider using CraigScrape::Posting.new 
    #
    # Scrapes a single Post Url, and returns a Posting object representing its contents.
    # Mostly here to preserve backwards-compatibility with the older api, CraigScrape::Listings.new "listing_url" does the same thing
    def scrape_full_post(post_url)
      CraigScrape::Posting.new post_url
    end

    # <b>This method is for legacy compatibility and is not recommended for use by new projects.</b>
    # Instead,  consider using the CraigScrape::each_post method.
    #
    # Continually scrapes listings, using the supplied url as a starting point, until 'count' summaries have been retrieved
    # or no more 'next page' links are avialable to be clicked on. Returns an array of PostSummary objects.
    def scrape_posts(listing_url, count)
      count_so_far = 0
      self.scrape_until(listing_url) {|post| count_so_far+=1; count < count_so_far }
    end

    # <b>This method is for legacy compatibility and is not recommended for use by new projects.</b>
    # Instead, consider using the CraigScrape::posts_since method.
    #
    # Continually scrapes listings, until the date newer_then has been reached, or no more 'next page' links are avialable to be clicked on.
    # Returns an array of PostSummary objects. Dates are based on the Month/Day 'datestamps' reported in the listing summaries. 
    # As such, time-based cutoffs are not supported here. The scrape_until method, utilizing the SummaryPost.full_post method could achieve
    # time-based cutoffs, at the expense of retrieving every post in full during enumerations.
    #
    # <b>Note:</b> The results will not include post summaries having the newer_then date themselves.
    def scrape_posts_since(listing_url, newer_then)
      self.scrape_until(listing_url) {|post| post.post_date <= newer_then}
    end
  end
  
  private
  
  # This  takes a fragments paramter, and turns it into actual urls
  def listing_urls_for(listing_fragments)
    listing_fragments.collect{ |lf|
      # This removes any /'s from he beginning of the fragment
      lf = $1 if /^\/(.*)/.match lf
      # This adds a '/' to the end of a path, so long as its not a query we're dealing with...
      lf += '/' unless lf.index '?'
      sites.collect { |site| '%s%s/%s' % [site_to_url_prefix,site,lf] }
    }.flatten
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

require 'listings'
require 'posting'
require 'geo_listings'