# = About scraper.rb
#
# This file defines:
# - the base class from which other parse objects inherit
# - Basic http and connection handling methods
# - html utility methods used by objects
# - Common Errors
# You should never need to include this file directly, as all of libcraigscrape's objects and methods 
# are loaded when you use <tt>require 'libcraigscrape'</tt> in your code.
#

# Scraper is a general-pupose base class for all libcraigscrape Objects. Scraper facilitates all http-related 
# functionality, and adds some useful helpers for dealing with eager-loading of http-objects and general html
# methods. It also contains the http-related cattr_accessors:
# 
# <b>logger</b> - a Logger object to debug http notices too. Defaults to nil
#

class CraigScrape::Scraper
  cattr_accessor :logger
  cattr_accessor :retries_on_404_fail
  cattr_accessor :sleep_between_404_retries

  self.retries_on_404_fail = 3
  self.sleep_between_404_retries = 3

  URL_PARTS = /^(?:([^\:]+)\:\/\/([^\/]*))?(.*)$/
  HTML_TAG  = /<\/?[^>]*>/
  # We have to specify this to nokogiri. Sometimes it tries to figure out encoding on its own, and craigslist users post crazy bytes sometimes  
  HTML_ENCODING = "UTF-8"

  HTTP_HEADERS = { "Cache-Control" => "no-cache", "Pragma" => "no-cache", 
    "Accept" => "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8", 
    "User-Agent" => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_6_8) AppleWebKit/535.19 (KHTML, like Gecko) Chrome/18.0.1025.168 Safari/535.19"}
  
  # Returns the full url that corresponds to this resource
  attr_reader :url

  class BadConstructionError < StandardError #:nodoc:
  end

  class ParseError < StandardError #:nodoc:
  end

  class BadUrlError < StandardError #:nodoc:
  end

  class FetchError < StandardError #:nodoc:
  end

  class ResourceNotFoundError < StandardError #:nodoc:
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
  def downloaded?; !@html_source.nil?; end

  # A URI object corresponding to this Scraped URL
  def uri
    @uri ||= URI.parse @url if @url
    @uri
  end

  # This method is mostly useful for our specs, but it's included in case anyone
  # else wants it. It returns all currently-defined instance variables, and is 
  # mostly useful for the specs. Probably this doesn't do what you think, and
  # should only be used to determine what's been parsed by the object thus-far.
  # (And does not include parseable attributes which have yet to be determined
  def attributes
    Hash[self.instance_variables.collect{|i| 
      [i.to_s.tr('@','').to_sym, instance_variable_get(i) ] }]
  end

  private
  
  # Returns text with all html tags removed.
  def strip_html(str)
    he_decode(str).gsub HTML_TAG, "" if str
  end
  
  # Easy way to fail noisily:
  def parse_error!(fields = nil)
    raise ParseError, "Error while parsing %s:\n %s%s" % [
      self.class.to_s, html, 
      (fields) ? ("\nRequired fields missing: %s" % fields.join(', ')) : ''] 
  end
  
  # Returns text with all html entities converted to respective ascii character.
  def he_decode(text); self.class.he_decode text; end

  # Returns text with all html entities converted to respective ascii character.
  def self.he_decode(text)
    HTMLEntities.new.decode text
  end
  
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
    logger.info "Requesting: %s" % [@url.inspect] if logger

    (case uri.scheme
      when 'file'
        # If this is a directory, we'll try to approximate http a bit by loading a '/index.html'
        File.read( File.directory?(uri.path) ? 
          "#{uri.path}/index.html" : uri.path , :encoding => 'BINARY')
      when /^http[s]?/
        fetch_http uri
      else
        raise BadUrlError, "Unknown URI scheme for the url: #{@url}"
    end).force_encoding("ISO-8859-1").encode("UTF-8")
  end

  def fetch_http(uri)
    fetch_attempts = 0
    resource_not_found_attempts = 0
      
    begin
      resp = Typhoeus.get uri.to_s, :followlocation =>  true, 
        :headers => HTTP_HEADERS

      if resp.response_code == 200
        resp.response_body
      else
        # Sometimes Craigslist seems to return 404's for no good reason, and a subsequent fetch will give you what you want
        raise ResourceNotFoundError, 'Unable to fetch "%s" (%s)' % [ @url, resp.response.code ]
      end
    rescue ResourceNotFoundError => err
      logger.info err.message if logger
      
      resource_not_found_attempts += 1
      
      if resource_not_found_attempts <= self.retries_on_404_fail
        sleep self.sleep_between_404_retries if self.sleep_between_404_retries
        logger.info 'Retrying ....' if logger
        retry
      else
        raise err
      end      
    end
  end
  
  # Returns a string, of the current URI's source code
  def html_source
    @html_source ||= fetch_uri uri if uri
    @html_source
  end
  
  # Returns an Nokogiri parse, of the current URI
  def html
    @html ||= Nokogiri::HTML html_source, nil, HTML_ENCODING if html_source
    @html
  end
end  
