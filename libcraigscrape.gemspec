Gem::Specification.new do |s|
  s.name        = 'libcraigscrape'
  s.version     = '1.1.1'
  s.date        = '2013-01-20'
  s.summary     = "quick, easy, craigslist parsing library that takes the monotony out of working with craigslist posts and listings"
  s.description = "An easy library to do the heavy lifting between you and
                  Craigslist's posting database. Given a URL, libcraigscrape
                  will follow links, scrape fields, and make ruby-sense out of
                  the raw html from craigslist's servers. libcraigscrape was
                  primarily developed to support the included craigwatch
                  script. See the included craigwatch script for examples of
                  libcraigscape in action, and (hopefully) to serve an
                  immediate craigscraping need."
  s.authors     = ["Chris DeRose"]
  s.email       = 'info@derosetechnologies.com'
  s.files       = Dir['Rakefile', '{bin,lib,man,test,spec}/**/**/**', 'Gemfile', 'CHANGELOG','COPYING', 'COPYING.LESSER', 'README*', 'LICENSE*'] & `git ls-files -z`.split("\0")
  s.homepage    = 'http://www.derosetechnologies.com/community/libcraigscrape'


  s.add_dependency( 'htmlentities', ['~>4.3'] )
  s.add_dependency( 'nokogiri',     ['>= 1.4.4'] )
  s.add_dependency( 'activerecord', ['~>3.2.9'] )
  s.add_dependency( 'activesupport', ['~>3.2.9'] )
  s.add_dependency( 'money', ['~>5.0.0'] )
  s.add_dependency( 'kwalify', ['~>0.7'] )
  s.add_dependency( 'actionmailer', ['~>3.2.9'] )
  s.add_dependency( 'sqlite3', ['~>1.3'] )
  s.add_dependency( 'typhoeus', ['~>0.5'] )
  s.add_development_dependency('rspec', [">= 2.12.0"])
  s.add_development_dependency('timecop', [">= 0.5.9"])
  s.add_development_dependency('vcr', [">= 2.4.0"])
end
