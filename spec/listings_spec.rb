# encoding: UTF-8
require 'spec_helper'

describe CraigScrape::Listings do
  context "listing_cta_ftl_112612.html" do
    subject { described_class.new( uri_for('listing_cta_ftl_112612.html') ) }
    specify{ subject.posts.should have(100).items }
    specify{ subject.posts.collect(&:post_date).uniq.should eq([Date.strptime('11/26/2012', '%m/%d/%Y')]) }
    specify{ subject.next_page_href.should eq('index100.html') }
    specify{ subject.posts[0].attributes.should eq({
        :label     => '#2009 Lexus GS 450h 4dr Car Hybrid (only 20,733 miles)',
        :href      => 'http://miami.craigslist.org/pbc/ctd/3437084110.html',
        :url       => 'http://miami.craigslist.org/pbc/ctd/3437084110.html',
        :location  => 'Lake Worth',
        :section   => 'dealer',
        :img_types => [:img],
        :post_date => Date.parse('2012/11/26') }) }
    specify{ subject.posts[1].attributes.should eq({
        :label     => 'we buy junk-bus-truck- car for cash!!$500-$5000-5612062848',
        :price     => 5000,
        :href      => 'http://miami.craigslist.org/brw/ctd/3437083983.html',
        :url       => 'http://miami.craigslist.org/pbc/ctd/3437083983.html',
        :location  => 'all over',
        :section   => 'dealer',
        :img_types => [],
        :post_date => Date.parse('2012/11/26') }) }
  end

  context 'listing_search_ppa_nyc_121212.html' do
    subject {  described_class.new( uri_for('listing_search_ppa_nyc_121212.html') ) }

    specify{ subject.posts.should have(100).items }
    specify{ subject.posts.collect(&:post_date).uniq.should eq(['12/12/2012', 
      '12/11/2012', '12/10/2012'].collect{|t| Date.strptime(t, "%m/%d/%Y") } ) }
    specify{ subject.next_page_href.should eq('http://newyork.craigslist.org/search/ppa?query=kenmore&srchType=A&s=100') }
  end
end
