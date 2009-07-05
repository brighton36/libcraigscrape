#!/usr/bin/ruby

require 'test/unit'
require File.dirname(__FILE__)+'/../lib/libcraigscrape'
require File.dirname(__FILE__)+'/libcraigscrape_test_helpers'

class CraigslistListingTest < Test::Unit::TestCase
  include LibcraigscrapeTestHelpers
  
  def test_pukes
    assert_raise(CraigScrape::Scraper::ParseError) do
      CraigScrape::Listings.new( relative_uri_for('google.html') ).posts
    end
  end

  def test_listings_parse 
    category = CraigScrape::Listings.new relative_uri_for('listing_samples/category_output.html')
    assert_equal 'index100.html', category.next_page_href
    assert_equal 100, category.posts.length

    category.posts[0..80].each do |l|
      assert_equal 4, l.post_date.month
      assert_equal 18, l.post_date.day
    end
    
    category2 = CraigScrape::Listings.new relative_uri_for('listing_samples/category_output_2.html')
    assert_equal 'index900.html', category2.next_page_href
    assert_equal 100, category2.posts.length
    
    long_search = CraigScrape::Listings.new relative_uri_for('listing_samples/long_search_output.html')
    assert_equal '/search/rea?query=house&minAsk=min&maxAsk=max&bedrooms=&s=800', long_search.next_page_href
    assert_equal 100, long_search.posts.length
    
    short_search = CraigScrape::Listings.new relative_uri_for('listing_samples/short_search_output.html')
    assert_equal nil, short_search.next_page_href
    assert_equal 93, short_search.posts.length
    
    mia_fua_index8900_052109 = CraigScrape::Listings.new relative_uri_for('listing_samples/mia_fua_index8900.5.21.09.html')
    assert_equal 'index9000.html', mia_fua_index8900_052109.next_page_href
    assert_equal 100, mia_fua_index8900_052109.posts.length
    # NOTE: This tests a subtle condition where there's a blank h4 tag, and we shouldn't need to eager-load,. since a solid inference can be made on the date, since its not the last h4 on the page
    # This actually happens quite a bit...
    mia_fua_index8900_052109.posts[0..13].each do |l|
      assert_equal 5, l.post_date.month
      assert_equal 15, l.post_date.day     
    end
    mia_fua_index8900_052109.posts[14..99].each do |l|
      assert_equal 5, l.post_date.month
      assert_equal 14, l.post_date.day
    end
    
    empty_listings = CraigScrape::Listings.new relative_uri_for('listing_samples/empty_listings.html')
    assert_equal nil, empty_listings.next_page_href
    assert_equal [], empty_listings.posts
  end

  def test_eager_post_loading
    # libcraigscrape is supposed to 'smart' when downloading postings that don't make 'sense' solely by looking at the listings.
    # I'm only seen this on occasion, but its annoying and craigslist seems to use a lot of approximations sometimes
    # The test page supplied is slightly adjusted to compensate for the lack of a web server when readng pages form the filesystem.
    
    fortmyers_art_index500_060909 = CraigScrape::Listings.new relative_uri_for('listing_samples/fortmyers_art_index.060909/fortmyers_art_index500.060909.html')
    fortmyers_art_index500_060909.posts[0..12].each do |l|
      assert_equal 5, l.post_date.month
      assert_equal 16, l.post_date.day
    end    
    fortmyers_art_index500_060909.posts[13..36].each do |l|
      assert_equal 5, l.post_date.month
      assert_equal 15, l.post_date.day
    end
    fortmyers_art_index500_060909.posts[37..41].each do |l|
      assert_equal 5, l.post_date.month
      assert_equal 14, l.post_date.day
    end    
    fortmyers_art_index500_060909.posts[42..55].each do |l|
      assert_equal 5, l.post_date.month
      assert_equal 13, l.post_date.day
    end
    fortmyers_art_index500_060909.posts[56..65].each do |l|
      assert_equal 5, l.post_date.month
      assert_equal 12, l.post_date.day
    end    
    fortmyers_art_index500_060909.posts[66..87].each do |l|
      assert_equal 5, l.post_date.month
      assert_equal 11, l.post_date.day
    end    
    fortmyers_art_index500_060909.posts[88..94].each do |l|
      assert_equal 5, l.post_date.month
      assert_equal 10, l.post_date.day
    end    
    assert_equal 4,  fortmyers_art_index500_060909.posts[95].post_date.month
    assert_equal 8,  fortmyers_art_index500_060909.posts[95].post_date.day
    assert_equal 2,  fortmyers_art_index500_060909.posts[96].post_date.month
    assert_equal 27, fortmyers_art_index500_060909.posts[96].post_date.day   
    assert_equal 2,  fortmyers_art_index500_060909.posts[97].post_date.month
    assert_equal 23, fortmyers_art_index500_060909.posts[97].post_date.day
    assert_equal 1,  fortmyers_art_index500_060909.posts[98].post_date.month
    assert_equal 14, fortmyers_art_index500_060909.posts[98].post_date.day
    assert_equal 12, fortmyers_art_index500_060909.posts[99].post_date.month
    assert_equal 16, fortmyers_art_index500_060909.posts[99].post_date.day

    # Now we'll do one of these elusive 'trailer' pages which don't seem to really make much sense. 
    # Best I can tell, it only comes after a page like the one tested just above
    fortmyers_art_index600_060909 = CraigScrape::Listings.new relative_uri_for('listing_samples/fortmyers_art_index.060909/fortmyers_art_index600.060909.html')   
    assert_equal "Husqvarna Viking Rose: Used Embroidery/Sewing Machine.  Instruction book, Video, Embroidery Unit, 4\" 4\" hoop, designs, tool box with accessories including 8 feet (A, B, C, D, E, J, P, U and zipper foot). $400.00 Firm. (941) 347-8014 or (352)638-4707.", fortmyers_art_index600_060909.posts[0].contents
    assert_equal "Husqvarna Viking Rose: Used Embroidery/Sewing Machine.  Instruction book, Video, Embroidery Unit, 4\" 4\" hoop, designs, tool box with accessories including 8 feet (A, B, C, D, E, J, P, U and zipper foot). $400.00 Firm. (941) 347-8014 or (352)638-4707.", fortmyers_art_index600_060909.posts[0].contents_as_plain
    assert_equal false, fortmyers_art_index600_060909.posts[0].deleted_by_author?
    assert_equal true, fortmyers_art_index600_060909.posts[0].downloaded?
    assert_equal false, fortmyers_art_index600_060909.posts[0].flagged_for_removal?
    assert_equal ["fort myers craigslist", "art & crafts"], fortmyers_art_index600_060909.posts[0].full_section
    assert_equal false, fortmyers_art_index600_060909.posts[0].has_img?
    assert_equal true, fortmyers_art_index600_060909.posts[0].has_pic?
    assert_equal true, fortmyers_art_index600_060909.posts[0].has_pic_or_img?
    assert_equal "Husqvarna Viking Rose Embroidery-Sewing Machine - $400 (Punta Gorda, Charlotte County)", fortmyers_art_index600_060909.posts[0].header
    assert_equal "Husqvarna Viking Rose Embroidery-Sewing Machine - $400 (Punta Gorda, Charlotte County)", fortmyers_art_index600_060909.posts[0].header_as_plain
    assert_equal "897549505.html", fortmyers_art_index600_060909.posts[0].href
    assert_equal [], fortmyers_art_index600_060909.posts[0].images
    assert_equal [:pic], fortmyers_art_index600_060909.posts[0].img_types
    assert_equal "Husqvarna Viking Rose Embroidery-Sewing Machine - $400", fortmyers_art_index600_060909.posts[0].label
    assert_equal "Punta Gorda, Charlotte County", fortmyers_art_index600_060909.posts[0].location
    assert_equal [], fortmyers_art_index600_060909.posts[0].pics
    assert_equal [0, 0, 0, 28, 10, 2008, 2, 302, true, "EDT"], fortmyers_art_index600_060909.posts[0].post_date.to_a
    assert_equal [0, 51, 21, 28, 10, 2008, 2, 302, true, "EDT"], fortmyers_art_index600_060909.posts[0].post_time.to_a
    assert_equal 897549505, fortmyers_art_index600_060909.posts[0].posting_id
    assert_equal 400.0, fortmyers_art_index600_060909.posts[0].price
    assert_equal nil, fortmyers_art_index600_060909.posts[0].reply_to
    assert_equal "art & crafts", fortmyers_art_index600_060909.posts[0].section
    assert_equal false, fortmyers_art_index600_060909.posts[0].system_post?
    assert_equal "Husqvarna Viking Rose Embroidery-Sewing Machine", fortmyers_art_index600_060909.posts[0].title
    
    assert_equal "Multiple artists' moving sale. Lots of unusual items including art, art supplies, ceramics and ceramic glazes, furniture, clothes, books, electronics, cd's and much more. Also for sale is alot of restaurant equpment.\r<br />\n\r<br />\nSale to be held at 3570 Bayshore Dr. next to Bayshore Coffee Co.\r<br />\n\r<br />\nSaturday 8:00 a.m. until 2:00 Rain or shine.\r<br />", fortmyers_art_index600_060909.posts[1].contents
    assert_equal "Multiple artists' moving sale. Lots of unusual items including art, art supplies, ceramics and ceramic glazes, furniture, clothes, books, electronics, cd's and much more. Also for sale is alot of restaurant equpment.\r\n\r\nSale to be held at 3570 Bayshore Dr. next to Bayshore Coffee Co.\r\n\r\nSaturday 8:00 a.m. until 2:00 Rain or shine.\r", fortmyers_art_index600_060909.posts[1].contents_as_plain
    assert_equal false, fortmyers_art_index600_060909.posts[1].deleted_by_author?
    assert_equal true, fortmyers_art_index600_060909.posts[1].downloaded?
    assert_equal false, fortmyers_art_index600_060909.posts[1].flagged_for_removal?
    assert_equal ["fort myers craigslist", "art & crafts"], fortmyers_art_index600_060909.posts[1].full_section
    assert_equal false, fortmyers_art_index600_060909.posts[1].has_img?
    assert_equal false, fortmyers_art_index600_060909.posts[1].has_pic?
    assert_equal false, fortmyers_art_index600_060909.posts[1].has_pic_or_img?
    assert_equal "ARTISTS' MOVING SALE-BAYSHORE (Naples)", fortmyers_art_index600_060909.posts[1].header
    assert_equal "ARTISTS' MOVING SALE-BAYSHORE (Naples)", fortmyers_art_index600_060909.posts[1].header_as_plain
    assert_equal "891513957.html", fortmyers_art_index600_060909.posts[1].href
    assert_equal [], fortmyers_art_index600_060909.posts[1].images
    assert_equal [], fortmyers_art_index600_060909.posts[1].img_types
    assert_equal "ARTISTS' MOVING SALE-BAYSHORE", fortmyers_art_index600_060909.posts[1].label
    assert_equal "Naples", fortmyers_art_index600_060909.posts[1].location
    assert_equal [], fortmyers_art_index600_060909.posts[1].pics
    assert_equal [0, 0, 0, 24, 10, 2008, 5, 298, true, "EDT"], fortmyers_art_index600_060909.posts[1].post_date.to_a
    assert_equal [0, 31, 9, 24, 10, 2008, 5, 298, true, "EDT"], fortmyers_art_index600_060909.posts[1].post_time.to_a
    assert_equal 891513957, fortmyers_art_index600_060909.posts[1].posting_id
    assert_equal nil, fortmyers_art_index600_060909.posts[1].price
    assert_equal "sale-891513957@craigslist.org", fortmyers_art_index600_060909.posts[1].reply_to
    assert_equal "art & crafts", fortmyers_art_index600_060909.posts[1].section
    assert_equal false, fortmyers_art_index600_060909.posts[1].system_post?
    assert_equal "ARTISTS' MOVING SALE-BAYSHORE", fortmyers_art_index600_060909.posts[1].title
    
    assert_equal "Tapestry sewing machine and embroidery arm luggage for Viking designer sewing machine.  Two years old in excellent condition.", fortmyers_art_index600_060909.posts[2].contents
    assert_equal "Tapestry sewing machine and embroidery arm luggage for Viking designer sewing machine.  Two years old in excellent condition.", fortmyers_art_index600_060909.posts[2].contents_as_plain
    assert_equal false, fortmyers_art_index600_060909.posts[2].deleted_by_author?
    assert_equal true, fortmyers_art_index600_060909.posts[2].downloaded?
    assert_equal false, fortmyers_art_index600_060909.posts[2].flagged_for_removal?
    assert_equal ["fort myers craigslist", "art & crafts"], fortmyers_art_index600_060909.posts[2].full_section
    assert_equal false, fortmyers_art_index600_060909.posts[2].has_img?
    assert_equal false, fortmyers_art_index600_060909.posts[2].has_pic?
    assert_equal false, fortmyers_art_index600_060909.posts[2].has_pic_or_img?
    assert_equal "tapestry sewing machine and embroidery arm luggage - $250 (Punta Gorda)", fortmyers_art_index600_060909.posts[2].header
    assert_equal "tapestry sewing machine and embroidery arm luggage - $250 (Punta Gorda)", fortmyers_art_index600_060909.posts[2].header_as_plain
    assert_equal "825684735.html", fortmyers_art_index600_060909.posts[2].href
    assert_equal [], fortmyers_art_index600_060909.posts[2].images
    assert_equal [], fortmyers_art_index600_060909.posts[2].img_types
    assert_equal "tapestry sewing machine and embroidery arm luggage - $250", fortmyers_art_index600_060909.posts[2].label
    assert_equal "Punta Gorda", fortmyers_art_index600_060909.posts[2].location
    assert_equal [], fortmyers_art_index600_060909.posts[2].pics
    assert_equal [0, 0, 0, 3, 9, 2008, 3, 247, true, "EDT"], fortmyers_art_index600_060909.posts[2].post_date.to_a
    assert_equal [0, 31, 15, 3, 9, 2008, 3, 247, true, "EDT"], fortmyers_art_index600_060909.posts[2].post_time.to_a
    assert_equal 825684735, fortmyers_art_index600_060909.posts[2].posting_id
    assert_equal 250.0, fortmyers_art_index600_060909.posts[2].price
    assert_equal "sale-825684735@craigslist.org", fortmyers_art_index600_060909.posts[2].reply_to
    assert_equal "art & crafts", fortmyers_art_index600_060909.posts[2].section
    assert_equal false, fortmyers_art_index600_060909.posts[2].system_post?
    assert_equal "tapestry sewing machine and embroidery arm luggage", fortmyers_art_index600_060909.posts[2].title
    
    assert_equal "Gorgeous and one of a kind!   Museum-collected artist Jay von Koffler's Aurora Series - cast glass nude sculpture - Aurora.  Mounted on marble and enhanced with bronze beak.   \r<br />\n\r<br />\nDimensions:  30x16x6\r<br />\nCall for appointment for studio viewing - 239.595.1793", fortmyers_art_index600_060909.posts[3].contents
    assert_equal "Gorgeous and one of a kind!   Museum-collected artist Jay von Koffler's Aurora Series - cast glass nude sculpture - Aurora.  Mounted on marble and enhanced with bronze beak.   \r\n\r\nDimensions:  30x16x6\r\nCall for appointment for studio viewing - 239.595.1793", fortmyers_art_index600_060909.posts[3].contents_as_plain
    assert_equal false, fortmyers_art_index600_060909.posts[3].deleted_by_author?
    assert_equal true, fortmyers_art_index600_060909.posts[3].downloaded?
    assert_equal false, fortmyers_art_index600_060909.posts[3].flagged_for_removal?
    assert_equal ["fort myers craigslist", "art & crafts"], fortmyers_art_index600_060909.posts[3].full_section
    assert_equal false, fortmyers_art_index600_060909.posts[3].has_img?
    assert_equal true, fortmyers_art_index600_060909.posts[3].has_pic?
    assert_equal true, fortmyers_art_index600_060909.posts[3].has_pic_or_img?
    assert_equal "Cast Glass Sculpture - Aurora - $2400 (Naples)", fortmyers_art_index600_060909.posts[3].header
    assert_equal "Cast Glass Sculpture - Aurora - $2400 (Naples)", fortmyers_art_index600_060909.posts[3].header_as_plain
    assert_equal "823516079.html", fortmyers_art_index600_060909.posts[3].href
    assert_equal [], fortmyers_art_index600_060909.posts[3].images
    assert_equal [:pic], fortmyers_art_index600_060909.posts[3].img_types
    assert_equal "Cast Glass Sculpture - Aurora - $2400", fortmyers_art_index600_060909.posts[3].label
    assert_equal "Naples", fortmyers_art_index600_060909.posts[3].location
    assert_equal [], fortmyers_art_index600_060909.posts[3].pics
    assert_equal [0, 0, 0, 2, 9, 2008, 2, 246, true, "EDT"], fortmyers_art_index600_060909.posts[3].post_date.to_a
    assert_equal [0, 35, 10, 2, 9, 2008, 2, 246, true, "EDT"], fortmyers_art_index600_060909.posts[3].post_time.to_a
    assert_equal 823516079, fortmyers_art_index600_060909.posts[3].posting_id
    assert_equal 2400.0, fortmyers_art_index600_060909.posts[3].price
    assert_equal "sale-823516079@craigslist.org", fortmyers_art_index600_060909.posts[3].reply_to
    assert_equal "art & crafts", fortmyers_art_index600_060909.posts[3].section
    assert_equal false, fortmyers_art_index600_060909.posts[3].system_post?
    assert_equal "Cast Glass Sculpture - Aurora", fortmyers_art_index600_060909.posts[3].title
  end
  
  def test_nasty_search_listings
     miami_search_sss_rack900_061809 = CraigScrape::Listings.new relative_uri_for('listing_samples/miami_search_sss_rack.6.18.09/miami_search_sss_rack900.6.18.09.html')
     assert_equal '/search/sss?query=rack&s=1000', miami_search_sss_rack900_061809.next_page_href
     
     miami_search_sss_rack1000_061809 = CraigScrape::Listings.new relative_uri_for('listing_samples/miami_search_sss_rack.6.18.09/miami_search_sss_rack1000.6.18.09.html')
     assert_equal nil, miami_search_sss_rack1000_061809.next_page_href
  end


end