= libcraigscrape - A craigslist URL-scraping support Library

An easy library to do the heavy lifting between you and Craigslist's posting database. Given a URL, libcraigscrape will
follow links, scrape fields, and make ruby-sense out of the raw html from craigslist's servers.

For more information, head to the {craiglist monitoring}[http://www.derosetechnologies.com/community/libcraigscrape] help section of our website.

== craigwatch
libcraigscrape was primarily developed to support the included craigwatch[link:files/bin/craigwatch.html] script. See the included craigwatch script for
examples of libcraigscape in action, and (hopefully) to serve an immediate craigscraping need.

== Installation

Install via RubyGems:

  sudo gem install libcraigscrape

== Usage

=== Scrape Craigslist Listings since Sep 10

On the 'miami.craigslist.org' site, using the query "search/sss?query=apple"

  require 'rubygems'
  require 'libcraigscrape'
  require 'date'
  require 'pp'
  
  miami_cl = CraigScrape.new 'us/fl/miami'
  miami_cl.posts_since(Time.parse('Sep 10'), 'search/sss?query=apple').each do |post|
    pp post  
  end

=== Scrape Last 225 Craigslist Listings

On the 'miami.craigslist.org'  under the 'apa' category

  require 'rubygems'
  require 'libcraigscrape'
  require 'pp'
  
  i=1
  CraigScrape.new('us/fl/miami').each_post('apa') do |post|
    break if i > 225
  	 i+=1
  	 pp post
  end

=== Multiple site with multiple section/search enumeration of posts

In Florida, with the exception of 'miami.craigslist.org' & 'keys.craigslist.org' sites, output each post in 
the 'crg' category and for the search 'artist needed'

  require 'rubygems'
  require 'libcraigscrape'
  require 'pp'
  
  non_sfl_sites = CraigScrape.new('us/fl', '- us/fl/miami', '- us/fl/keys')
  non_sfl_sites.each_post('crg', 'search/sss?query=artist+needed') do |post|
  	 pp post
  end

=== Scrape Single Craigslist Posting

This grabs the full details under the specific post http://miami.craigslist.org/mdc/sys/1140808860.html

  require 'rubygems'
  require 'libcraigscrape'
  
  post = CraigScrape::Posting.new 'http://miami.craigslist.org/mdc/sys/1140808860.html'
  puts "(%s) %s:\n %s" % [ post.post_time.strftime('%b %d'), post.title, post.contents_as_plain ]

=== Scrape Single Craigslist Listing

This grabs the post summaries of the single listings at http://miami.craigslist.org/search/sss?query=laptop

  require 'rubygems'
  require 'libcraigscrape'
  
  listing = CraigScrape::Listings.new 'http://miami.craigslist.org/search/sss?query=laptop'
  puts 'Found %d posts for the search "laptop" on this page' % listing.posts.length

== Author
- Chris DeRose (cderose@derosetechnologies.com)
- DeRose Technologies, Inc. http://www.derosetechnologies.com

== License

See COPYING[link:files/COPYING.html]
