require 'timecop'
require_relative '../lib/libcraigscrape'

def uri_for(filename)
  'file://%s' % [ File.dirname(File.expand_path(__FILE__)),
    'assets', filename].join('/')
end

