#!/usr/bin/ruby

require 'test/unit'
require File.dirname(__FILE__)+'/../lib/libcraigscrape'
require File.dirname(__FILE__)+'/libcraigscrape_test_helpers'

class CraigslistListingTest < Test::Unit::TestCase
  include LibcraigscrapeTestHelpers
  
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
    
    assert_equal "Multiple artists' moving sale. Lots of unusual items including art, art supplies, ceramics and ceramic glazes, furniture, clothes, books, electronics, cd's and much more. Also for sale is alot of restaurant equpment.\r<br>\n\r<br>\nSale to be held at 3570 Bayshore Dr. next to Bayshore Coffee Co.\r<br>\n\r<br>\nSaturday 8:00 a.m. until 2:00 Rain or shine.\r<br>", fortmyers_art_index600_060909.posts[1].contents
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
    
    assert_equal "Gorgeous and one of a kind!   Museum-collected artist Jay von Koffler's Aurora Series - cast glass nude sculpture - Aurora.  Mounted on marble and enhanced with bronze beak.   \r<br>\n\r<br>\nDimensions:  30x16x6\r<br>\nCall for appointment for studio viewing - 239.595.1793", fortmyers_art_index600_060909.posts[3].contents
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
          
    mia_search_kitten031510 = CraigScrape::Listings.new relative_uri_for('listing_samples/mia_search_kitten.3.15.10.html')
    assert_equal "Adopt a 7 month on kitten- $75", mia_search_kitten031510.posts[0].label
    assert_equal [0, 0, 0, 15, 3, 2010, 1, 74, true, "EDT"], mia_search_kitten031510.posts[0].post_date.to_a
    assert_equal "Adorable Kitten! Free!!!", mia_search_kitten031510.posts[1].label
    assert_equal [0, 0, 0, 15, 3, 2010, 1, 74, true, "EDT"], mia_search_kitten031510.posts[1].post_date.to_a
    assert_equal "KITTENS,5 months, 1 Russian blue, 1 grey & white,vac spy/neu,$35fee ea", mia_search_kitten031510.posts[2].label
    assert_equal [0, 0, 0, 13, 3, 2010, 6, 72, false, "EST"], mia_search_kitten031510.posts[2].post_date.to_a
    assert_equal "Kitties need a good home", mia_search_kitten031510.posts[3].label
    assert_equal [0, 0, 0, 13, 3, 2010, 6, 72, false, "EST"], mia_search_kitten031510.posts[3].post_date.to_a
    assert_equal "7 week old kittens for adoption", mia_search_kitten031510.posts[4].label
    assert_equal [0, 0, 0, 13, 3, 2010, 6, 72, false, "EST"], mia_search_kitten031510.posts[4].post_date.to_a
    assert_equal "Adorable Orange Kitten Free to Good Home", mia_search_kitten031510.posts[5].label
    assert_equal [0, 0, 0, 12, 3, 2010, 5, 71, false, "EST"], mia_search_kitten031510.posts[5].post_date.to_a
    assert_equal "7 month old kitten free to good home", mia_search_kitten031510.posts[6].label
    assert_equal [0, 0, 0, 12, 3, 2010, 5, 71, false, "EST"], mia_search_kitten031510.posts[6].post_date.to_a
    assert_equal "FEMALE KITTEN FOR GOOD HOME", mia_search_kitten031510.posts[7].label
    assert_equal [0, 0, 0, 9, 3, 2010, 2, 68, false, "EST"], mia_search_kitten031510.posts[7].post_date.to_a
    assert_equal "Kitten", mia_search_kitten031510.posts[8].label
    assert_equal [0, 0, 0, 4, 3, 2010, 4, 63, false, "EST"], mia_search_kitten031510.posts[8].post_date.to_a
    assert_equal "Kitties need a good home", mia_search_kitten031510.posts[9].label
    assert_equal [0, 0, 0, 4, 3, 2010, 4, 63, false, "EST"], mia_search_kitten031510.posts[9].post_date.to_a
    assert_equal "Persain Cat And Tabby Cat", mia_search_kitten031510.posts[10].label
    assert_equal [0, 0, 0, 1, 3, 2010, 1, 60, false, "EST"], mia_search_kitten031510.posts[10].post_date.to_a
    assert_equal "Tabby female kitten in a parking lot needs your help", mia_search_kitten031510.posts[11].label
    assert_equal [0, 0, 0, 23, 2, 2010, 2, 54, false, "EST"], mia_search_kitten031510.posts[11].post_date.to_a
    assert_equal "Spring is almost officially here, grow your family, adopt a kitty!", mia_search_kitten031510.posts[12].label
    assert_equal [0, 0, 0, 22, 2, 2010, 1, 53, false, "EST"], mia_search_kitten031510.posts[12].post_date.to_a
    assert_equal "Many adorable kittens for adoption!", mia_search_kitten031510.posts[13].label
    assert_equal [0, 0, 0, 22, 2, 2010, 1, 53, false, "EST"], mia_search_kitten031510.posts[13].post_date.to_a
    assert_equal "2 free cats/kitten to good home", mia_search_kitten031510.posts[14].label
    assert_equal [0, 0, 0, 19, 2, 2010, 5, 50, false, "EST"], mia_search_kitten031510.posts[14].post_date.to_a
    assert_equal "BEAUTIFUL KITTENS", mia_search_kitten031510.posts[15].label
    assert_equal [0, 0, 0, 19, 2, 2010, 5, 50, false, "EST"], mia_search_kitten031510.posts[15].post_date.to_a
    assert_equal "MANY new adorable kittens for good homes!!!", mia_search_kitten031510.posts[16].label
    assert_equal [0, 0, 0, 18, 2, 2010, 4, 49, false, "EST"], mia_search_kitten031510.posts[16].post_date.to_a
    assert_equal "Kitten living in a parking lot needs your help", mia_search_kitten031510.posts[17].label
    assert_equal [0, 0, 0, 16, 2, 2010, 2, 47, false, "EST"], mia_search_kitten031510.posts[17].post_date.to_a
    assert_equal "BEAUTIFUL 8 WEEK KITTENS", mia_search_kitten031510.posts[18].label
    assert_equal [0, 0, 0, 16, 2, 2010, 2, 47, false, "EST"], mia_search_kitten031510.posts[18].post_date.to_a
    assert_equal "ORANGE TABBY KITTEN", mia_search_kitten031510.posts[19].label
    assert_equal [0, 0, 0, 13, 2, 2010, 6, 44, false, "EST"], mia_search_kitten031510.posts[19].post_date.to_a
    assert_equal "Lots of kittens to choose from! Pics!!", mia_search_kitten031510.posts[20].label
    assert_equal [0, 0, 0, 13, 2, 2010, 6, 44, false, "EST"], mia_search_kitten031510.posts[20].post_date.to_a

  end

  def test_new_listing_span051710_labels
    new_listing_span051710 = CraigScrape::Listings.new relative_uri_for('listing_samples/new_listing_span.4.17.10.html')
    
    assert_equal " Art Directly for Sale from the Artist", new_listing_span051710.posts[0].label
    assert_equal "Wall Art, Contemporary Abstract by Vista Gallories", new_listing_span051710.posts[1].label
    assert_equal "Gary George \"Darice\" Giclee Semi Nude Woman COA NEW", new_listing_span051710.posts[2].label
    assert_equal "electric clock kits", new_listing_span051710.posts[3].label
    assert_equal "Artificial Bonsai arrangements (3)", new_listing_span051710.posts[4].label
    assert_equal "Wall Canvass", new_listing_span051710.posts[5].label
    assert_equal "seeking drafting table", new_listing_span051710.posts[6].label
    assert_equal "great electrical  air compressor LIKE NEW", new_listing_span051710.posts[7].label
    assert_equal "Mannequin Male Full Torso Display Form", new_listing_span051710.posts[8].label
    assert_equal "CRAB NETS 12 X12 X7", new_listing_span051710.posts[9].label
    assert_equal "Hundreds of Loose Beads from old Jewelry &newer Seed Beads arts crafts", new_listing_span051710.posts[10].label
    assert_equal "HUNDREDS OF LOOSE BEADS VARIETY FOR ARTS CRAFTS MAKING JEWELRY", new_listing_span051710.posts[11].label
    assert_equal "consolidated b-24d liberator", new_listing_span051710.posts[12].label
    assert_equal "nort american p-51b mustang", new_listing_span051710.posts[13].label
    assert_equal "spitfire mk.ixc kenley wing", new_listing_span051710.posts[14].label
    assert_equal "republic p-47d thunderbolt bubbletop", new_listing_span051710.posts[15].label
    assert_equal "Artistic & Commercial Mannequin Female Torso Ladies Form", new_listing_span051710.posts[16].label
    assert_equal "Start your own Bath & Beauty company", new_listing_span051710.posts[17].label
    assert_equal "hurricane mk.2 eagle squadron", new_listing_span051710.posts[18].label
    assert_equal "HUGE Lot Iron-Ons Appliques-Craft Decals-Fabric-Holidays, Looney Tunes", new_listing_span051710.posts[19].label
    assert_equal "typhoon mk.ib", new_listing_span051710.posts[20].label
    assert_equal "Beautiful Handmade Sea Shell Candles - Great Gift Ideas", new_listing_span051710.posts[21].label
    assert_equal "bristol beaufighter mk.vi", new_listing_span051710.posts[22].label
    assert_equal "hawker tempest mk.v", new_listing_span051710.posts[23].label
    assert_equal "gloster meteor f.1.v.1", new_listing_span051710.posts[24].label
    assert_equal "Painted art picture with frame 43\"L X 31\"H", new_listing_span051710.posts[25].label
    assert_equal "messerschmitt me 410b-2/u4", new_listing_span051710.posts[26].label
    assert_equal "Matching Set 4 Wild Cat Prints Framed in Gold-Cheetah, Leopard, Lion", new_listing_span051710.posts[27].label
    assert_equal "CATS IN PAJAMAS FRAMED PRINT-SIGNED-KATHRYN RAMSEUR GLICK 1995-NUMBERD", new_listing_span051710.posts[28].label
    assert_equal "4 Needlecraft Books", new_listing_span051710.posts[29].label
    assert_equal "UNIQUE HIDDEN ANGEL PRINT-MATTED & FRAMED Retails $89.99-Signed-Ocampa", new_listing_span051710.posts[30].label
    assert_equal "royal air force hawker hurricane", new_listing_span051710.posts[31].label
    assert_equal "UNIQUE LARGE PRINT-HANDS OF TIME-BY OCTAVIO - RETAILS $139.00", new_listing_span051710.posts[32].label
    assert_equal "LARGE COBBLESTONE FRAMED PRINT LANDSCAPE BY HAILS - SIGNED 1996", new_listing_span051710.posts[33].label
    assert_equal "zero fighier", new_listing_span051710.posts[34].label
    assert_equal "UNIQUE 1 OF A KIND -HANDMADE JEWELRY", new_listing_span051710.posts[35].label
    assert_equal "YARN YARN YARN", new_listing_span051710.posts[36].label
    assert_equal "2012 Original Paintings", new_listing_span051710.posts[37].label
    assert_equal "picture with birds songs$10", new_listing_span051710.posts[38].label
    assert_equal "Modern original Still Life painting SIGNED", new_listing_span051710.posts[39].label
    assert_equal "afghans", new_listing_span051710.posts[40].label
    assert_equal "Teamwork Print-Inspirational", new_listing_span051710.posts[41].label
    assert_equal "Large number of ceramic molds for sale at Reasonable prices!", new_listing_span051710.posts[42].label
    assert_equal "1982  Knitting Collection", new_listing_span051710.posts[43].label
    assert_equal "Bell Small Wilton Cake Pan", new_listing_span051710.posts[44].label
    assert_equal "Winnie The Pooh Wilton Cake Pan", new_listing_span051710.posts[45].label
    assert_equal "Holly Hobbie Wilton Cake Pan", new_listing_span051710.posts[46].label
    assert_equal "Quilt~ Hand Crafted~Beautiful hand crafted quilted wall hanging", new_listing_span051710.posts[47].label
    assert_equal "Pretty Pictures", new_listing_span051710.posts[48].label
    assert_equal "messerschmitt bf 109d", new_listing_span051710.posts[49].label
    assert_equal "douglas a-20 g havoc", new_listing_span051710.posts[50].label
    assert_equal "me262a-1a/u3 reconnaissance", new_listing_span051710.posts[51].label
    assert_equal "p-36 pearl harbor defender", new_listing_span051710.posts[52].label
    assert_equal "spitfire mk.xivc", new_listing_span051710.posts[53].label
    assert_equal "ART KIT", new_listing_span051710.posts[54].label
    assert_equal "Unique Recycled Glass  Melted Bottle Cheese Trays and dishes", new_listing_span051710.posts[55].label
    assert_equal "T-SHIRT HEAT PRESS", new_listing_span051710.posts[56].label
    assert_equal "Metal Alligator Wall Art With Neon Light", new_listing_span051710.posts[57].label
    assert_equal "SOLAR GARDEN DECO LITES", new_listing_span051710.posts[58].label
    assert_equal "POMPELL CHEETAH FRAMED ART PRINT & MATCHING THROW PILLOWS 35 X 27", new_listing_span051710.posts[59].label
    assert_equal "\"YOU CAN DRAW\" 8 BOOKS IN 1", new_listing_span051710.posts[60].label
    assert_equal "ROSEART SMART 3 IN 1 PORTFOLIO", new_listing_span051710.posts[61].label
    assert_equal "art supplies", new_listing_span051710.posts[62].label
    assert_equal "ZINC OXIDE", new_listing_span051710.posts[63].label
    assert_equal "Wood Veneer", new_listing_span051710.posts[64].label
    assert_equal "Scrapbook magazines", new_listing_span051710.posts[65].label
    assert_equal "henri plisson fine art", new_listing_span051710.posts[66].label
    assert_equal "Beautiful brand new bronze Fountain", new_listing_span051710.posts[67].label
    assert_equal "Contemporary fine arts and quality handmade crafts", new_listing_span051710.posts[68].label
    assert_equal "p-61 black widow", new_listing_span051710.posts[69].label
    assert_equal "New Abstract Oil Paintings for Sale - Made in USA!", new_listing_span051710.posts[70].label
    assert_equal "Fun Stamps", new_listing_span051710.posts[71].label
    assert_equal "For Sale - Salvador Dali Print - Lincoln in Dalivision", new_listing_span051710.posts[72].label
    assert_equal "For Sale Print on Canvas Gone with the Wind", new_listing_span051710.posts[73].label
    assert_equal "For Sale - Two Framed Egyptian Prints on Papyrus", new_listing_span051710.posts[74].label
    assert_equal "4/16 and 4/17 Gallery art unframed - gallery closed", new_listing_span051710.posts[75].label
    assert_equal "Sewing patterns TONS 4/16 and 4/17", new_listing_span051710.posts[76].label
    assert_equal "For Sale 4 panel Asian folding Art", new_listing_span051710.posts[77].label
    assert_equal "@@@ Original Artwork on Print & signed", new_listing_span051710.posts[78].label
    assert_equal "Three Moai Tikis", new_listing_span051710.posts[79].label
    assert_equal "Stained Glass Kiln", new_listing_span051710.posts[80].label
    assert_equal "Tiki Carved From Palm", new_listing_span051710.posts[81].label
    assert_equal "The End is Near! 2012 painting", new_listing_span051710.posts[82].label
    assert_equal "PAINTING BY KENT", new_listing_span051710.posts[83].label
    assert_equal "ART SALE! ONLY $29 to $69 FOR THESE ORIGINAL PHOTO ART PIECES!", new_listing_span051710.posts[84].label
    assert_equal " Contemporary Painting for Sale!!!", new_listing_span051710.posts[85].label
    assert_equal "gift baskets and bears", new_listing_span051710.posts[86].label
    assert_equal "Eyvind Earle Nocturne Serigraph", new_listing_span051710.posts[87].label
    assert_equal "jo's watercolors", new_listing_span051710.posts[88].label
    assert_equal "Eyvind Earle Carmel Cypress Serigraph", new_listing_span051710.posts[89].label
    assert_equal "Eyvind Earle Stardust Blue Serigraph", new_listing_span051710.posts[90].label
    assert_equal "Portraits painted of your loved ones", new_listing_span051710.posts[91].label
    assert_equal "Attn Crafters! 10 Strands of Lemons", new_listing_span051710.posts[92].label
    assert_equal "SARAH E. AND GULLS", new_listing_span051710.posts[93].label
    assert_equal "cavalier 98", new_listing_span051710.posts[94].label
    assert_equal "model kit fairey swordfish mk 2", new_listing_span051710.posts[95].label
    assert_equal "jo's watercolors", new_listing_span051710.posts[96].label
    assert_equal "Stampin' Up Rubber Stamps", new_listing_span051710.posts[97].label
    assert_equal "Wyland Oil Painting", new_listing_span051710.posts[98].label
    assert_equal "Denim Fabric Blocks for Crafts", new_listing_span051710.posts[99].label
  end
  
end