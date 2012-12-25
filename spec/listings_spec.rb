# encoding: UTF-8
require 'spec_helper'

describe CraigScrape::Listings do
  context "listing_cta_ftl_112612.html" do
    subject { described_class.new( uri_for('listing_cta_ftl_112612.html') ) }
    specify{ subject.posts.should have(100).items }
    specify{ subject.posts.collect(&:post_date).uniq.should eq([Date.strptime('11/26/2012', '%m/%d/%Y')]) }
    specify{ subject.next_page_href.should eq('index100.html') }
  end

  context 'listing_search_ppa_nyc_121212.html' do
    subject {  described_class.new( uri_for('listing_search_ppa_nyc_121212.html') ) }

    specify{ subject.posts.should have(100).items }
    specify{ subject.posts.collect(&:post_date).uniq.should eq(['12/12/2012', 
      '12/11/2012', '12/10/2012'].collect{|t| Date.strptime(t, "%m/%d/%Y") } ) }
    specify{ subject.next_page_href.should eq('http://newyork.craigslist.org/search/ppa?query=kenmore&srchType=A&s=100') }
  end
end
