# TODO: file rdoc

require 'scraper'

class CraigScrape
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