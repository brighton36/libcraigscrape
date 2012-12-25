# encoding: UTF-8
require 'spec_helper'

describe CraigScrape::Listings do
  context "listing_cta_ftl_112612.html" do
    subject { described_class.new( uri_for('listing_cta_ftl_112612.html') ) }
    specify{ subject.posts.should have(100).items }
    specify{ subject.posts.collect(&:post_date).uniq.should eq([Time.zone.parse('2012-11-26 00:00:00')]) }
    specify{ subject.next_page_href.should eq('index100.html') }
  end

  context 'listing_search_ppa_nyc_121212.html' do
    subject {  described_class.new( uri_for('listing_search_ppa_nyc_121212.html') ) }

    specify{ subject.posts.should have(100).items }
    specify{ subject.posts.collect(&:post_date).uniq.should eq(['2012-12-12 00:00:00', 
      '2012-12-11 00:00:00', '2012-12-10 00:00:00'].collect{|t| Time.zone.parse(t) }) }
    specify{ subject.next_page_href.should eq('http://newyork.craigslist.org/search/ppa?query=kenmore&srchType=A&s=100') }
  end
end
