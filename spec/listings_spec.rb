# encoding: UTF-8
require 'spec_helper'

describe CraigScrape::Listings do
  let(:end_of_2012) { Time.local(2012,12,31) }
  let(:start_of_2013) { Time.local(2013,1,20) }

  context "listing_cta_ftl_112612.html" do
    before{ Timecop.freeze(start_of_2013) }
    after{ Timecop.return }
    
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
        :price     => Money.new(500000, 'USD'),
        :href      => 'http://miami.craigslist.org/brw/ctd/3437083983.html',
        :url       => 'http://miami.craigslist.org/brw/ctd/3437083983.html',
        :location  => 'all over',
        :section   => 'dealer',
        :img_types => [],
        :post_date => Date.parse('2012/11/26') }) }
  end

  context 'listing_search_ppa_nyc_121212.html' do
    before{ Timecop.freeze(end_of_2012) }
    after{ Timecop.return }

    subject {  described_class.new( uri_for('listing_search_ppa_nyc_121212.html') ) }

    specify{ subject.posts.should have(100).items }
    specify{ subject.posts.collect(&:post_date).uniq.should eq(['12/12/2012', 
      '12/11/2012', '12/10/2012'].collect{|t| Date.strptime(t, "%m/%d/%Y") } ) }
    specify{ subject.next_page_href.should eq('http://newyork.craigslist.org/search/ppa?query=kenmore&srchType=A&s=100') }
    specify{ subject.posts[0].attributes.should eq({
        :label     => 'Staten island appliance repair',
        :href      => 'http://newyork.craigslist.org/stn/app/3440211032.html',
        :url       => 'http://newyork.craigslist.org/stn/app/3440211032.html',
        :location  => '7184487435',
        :section   => 'appliances - by owner',
        :img_types => [],
        :post_date => Date.parse('2012/12/12') }) }
    specify{ subject.posts[1].attributes.should eq({
        :label     => 'Kenmore 5200 BTU Air Conditioner',
        :href      => 'http://newyork.craigslist.org/mnh/app/3474408782.html',
        :url       => 'http://newyork.craigslist.org/mnh/app/3474408782.html',
        :location  => 'Upper West Side',
        :section   => 'appliances - by owner',
        :img_types => [:pic],
        :price     =>  Money.new(3000, 'USD'),
        :post_date => Date.parse('2012/12/12') }) }
  end
  
  context "listing_rea_miami_123012.html" do
    before{ Timecop.freeze(end_of_2012) }
    after{ Timecop.return }

    subject { described_class.new( uri_for('listing_rea_miami_123012.html') ) }
    specify{ subject.posts.should have(100).items }
    specify{ subject.posts[0].attributes.should eq({
        :label     => '3bd 2ba Home for Sale in Miami - Reduced',
        :href      => 'http://miami.craigslist.org/mdc/reb/3478403162.html',
        :url       => 'http://miami.craigslist.org/mdc/reb/3478403162.html',
        :location  => 'Miami',
        :section   => 'broker',
        :img_types => [:img],
        :price     =>  Money.new(24900000, 'USD'),
        :post_date => Date.parse('2012/12/30') }) }
    specify{ subject.posts[12].attributes.should eq({
        :label     => 'Miami, FL Home for Sale - 4bd 3ba/1hba',
        :href      => 'http://miami.craigslist.org/mdc/reb/3478359527.html',
        :url       => 'http://miami.craigslist.org/mdc/reb/3478359527.html',
        :location  => 'Other',
        :section   => 'broker',
        :img_types => [:img],
        :price     =>  Money.new(45800000, 'USD'),
        :post_date => Date.parse('2012/12/30') }) }
  end
end
