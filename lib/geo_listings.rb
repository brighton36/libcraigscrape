# TODO: file rdoc

require 'scraper'

class CraigScrape
  
  # GeoListings represents a parsed Craigslist geo lisiting page. (i.e. {'http://geo.craigslist.org/iso/us'}[http://geo.craigslist.org/iso/us]) 
  # These list all the craigslist sites in a given region.
  class GeoListings < Scraper
    GEOLISTING_BASE_URL = %{http://geo.craigslist.org/iso/}
    
    LOCATION_NAME    = /[ ]*\>[ ](.+)[ ]*/
    PATH_SCANNER     = /(?:\\\/|[^\/])+/
    URL_HOST_PART    = /^[^\:]+\:\/\/([^\/]+)[\/]?$/
    SITE_PREFIX      = /^([^\.]+)/
    FIND_SITES_PARTS = /^[ ]*([\+|\-]?)[ ]*(.+)[ ]*/

    class BadGeoListingPath < StandardError #:nodoc:
    end

    # The geolisting constructor works like all other Scraper objects, in that it accepts a string 'url'.
    # See the Craigscrape.find_sites for a more powerful way to find craigslist sites.
    def initialize(init_via = nil)
      super(init_via)

      # Validate that required fields are present, at least - if we've downloaded it from a url
      parse_error! unless location
    end
  
    # Returns the GeoLocation's full name
    def location
      unless @location
        cursor = html % 'h3 > b > a:first-of-type'
        cursor = cursor.next_node if cursor       
        @location = $1 if cursor and LOCATION_NAME.match he_decode(cursor.to_s)
      end
      
      @location
    end
  
    # Returns a hash of site name to urls in the current listing
    def sites
      unless @sites
        @sites = {}
        (html / 'div#list > a').each do |el_a|
          site_name = he_decode strip_html(el_a.inner_html)
          @sites[site_name] = $1 if URL_HOST_PART.match el_a[:href]
        end
      end
      
      @sites
    end
    
    # This method will return an array of all possible sites that match the specified location path.
    # Sample location paths:
    # - us/ca
    # - us/fl/miami
    # - jp/fukuoka
    # - mx
    # Here's how location paths work. 
    # - The components of the path are to be separated by '/' 's.
    # - Up to (and optionally, not including) the last component, the path should correspond against a valid GeoLocation url with the prefix of 'http://geo.craigslist.org/iso/'
    # - the last component can either be a site's 'prefix' on a GeoLocation page, or, the last component can just be a geolocation page itself, in which case all the sites on that page are selected.
    # - the site prefix is the first dns record in a website listed on a GeoLocation page. (So, for the case of us/fl/miami , the last 'miami' corresponds to the 'south florida' link on {'http://geo.craigslist.org/iso/us/fl'}[http://geo.craigslist.org/iso/us/fl]
    def self.sites_in_path(full_path, base_url = GEOLISTING_BASE_URL)
      # the base_url parameter is mostly so we can test this method
      
      # Unfortunately - the easiest way to understand much of this is to see how craigslist returns 
      # these geolocations. Watch what happens when you request us/fl/non-existant/page/here.
      # I also made this a little forgiving in a couple ways not specified with official support, per 
      # the rules above.
      full_path_parts = full_path.scan PATH_SCANNER

      # We'll either find a single site in this loop andf return that, or, we'll find a whole listing
      # and set the geo_listing object to reflect that
      geo_listing = nil
      full_path_parts.each_with_index do |part, i|

        # Let's un-escape the path-part, if needed:
        part.gsub! "\\/", "/"        
        
        # If they're specifying a single site, this will catch and return it immediately
        site = geo_listing.sites.find{ |n,s| 
          (SITE_PREFIX.match s and $1 == part) or n == part
        } if geo_listing
        
        # This returns the site component of the found array
        return [site.last] if site 
        
        begin
          # The URI escape is mostly needed to translate the space characters
          l = GeoListings.new base_url+full_path_parts[0...i+1].collect{|p| URI.escape p}.join('/')
        rescue CraigScrape::Scraper::FetchError
          bad_geo_path! full_path
        end

        # This probably tells us the first part of the path was 'correct', but not the rest:
        bad_geo_path! full_path if geo_listing and geo_listing.location == l.location

        geo_listing = l
      end

      # We have a valid listing page we found, and we can just return all the sites on it:
      geo_listing.sites.collect{|n,s| s }
    end

    # find_sites takes a single array of strings as an argument. Each string is to be either a location path 
    # (see sites_in_path), or a full site (in canonical form - ie "memphis.craigslist.org"). Optionally,
    # each of this may/should contain a '+' or '-' prefix to indicate whether the string is supposed to 
    # include sites from the master list, or remove them from the list. If no '+' or'-' is
    # specified, the default assumption is '+'. Strings are processed from left to right, which gives
    # a high degree of control over the selection set. Examples:
    # - find_sites "us/fl", "- miami.craigslist.org"
    # - find_sites "us", "- us/nm"
    # - find_sites "us", "- us/ny", "+ newyork.craigslist.org"
    # - find_sites "us/ny", "us/id", "caribbean.craigslist.org"
    # There's a lot of flexibility here, you get the idea.
    def self.find_sites(specs, base_url = GEOLISTING_BASE_URL)
      ret = []
      
      specs.each do |spec|
        (op,spec = $1,$2) if FIND_SITES_PARTS.match spec

        spec = (spec.include? '.')  ? [spec] : sites_in_path(spec, base_url) 

        if op == '-'
          ret -= spec
        else
          # We're adding. Just need to make sure we don't list the same thing twice:
          spec.each{|s| ret << s unless ret.include? s}
        end
      end
      
      ret
    end

    private
    
    def self.bad_geo_path!(path)
      raise BadGeoListingPath, "Unable to load path #{path.inspect}, either you're having problems connecting to Craiglist, or your path is invalid."
    end
    
  end
end