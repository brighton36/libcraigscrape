require_relative '../lib/libcraigscrape'
# require_relative '../test/libcraigscrape_test_helpers'
# include LibcraigscrapeTestHelpers 

def uri_for(filename)
  'file://%s' % [ File.dirname(File.expand_path(__FILE__)),
    'assets', filename].join('/')
end
