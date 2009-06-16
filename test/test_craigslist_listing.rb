#!/usr/bin/ruby

require File.dirname(__FILE__)+'/../lib/libcraigscrape'
require 'test/unit'

class CraigslistListingTest < Test::Unit::TestCase

  def test_pukes
    # TODO
#    assert_raise(CraigScrape::ParseError){ CraigScrape::PostFull.new relative_uri_for('google.html') }
#    assert_raise(CraigScrape::ParseError){ CraigScrape::Listings.new relative_uri_for('google.html') }
  end

  def test_listing_parse
    search_html_one = <<EOD
<p> Apr 18 - <a href="/brw/reb/1128608404.html">Losing your house?  You'll need this New Loan Mod Video -</a><font size="-1"> (W. Woodland)</font> <span class="p"> img</span> &lt;&lt;<i><a href="/reb/">real&nbsp;estate - by broker</a></i></p>
EOD
    search_html_two = <<EOD
<p> Jan 4 - <a href="/mdc/reb/1128609783.html">$348000 / 1br - Large 1/1 plus office on 49th Floor. 5-Star NEW Condo. Great Views -</a><font size="-1"> (Miami)</font> <span class="p"> pic&nbsp;img</span> &lt;&lt;<i><a href="/reb/">real&nbsp;estate - by broker</a></i></p>
EOD
    search_html_three = <<EOD
<p> Dec 31 - <a href="/mdc/reb/1128520894.html">$22,000 HOME -ADULT COMMUNITY BOYNTON BEACH -</a> <span class="p"> pic</span> &lt;&lt;<i><a href="/reb/">real&nbsp;estate - by broker</a></i></p> 
EOD
    search_html_four = <<EOD
<p> Jul 22 - <a href="/mdc/reb/1128474725.html">$325000 / 3br - GOOD DEAL GREAT HOUSE AND LOCATION -</a><font size="-1"> (CORAL GABLES)</font> &lt;&lt;<i><a href="/reb/">real&nbsp;estate - by broker</a></i></p>
EOD
    search_html_five = <<EOD
<p> Apr  9 - <a href="/pbc/boa/1115308178.html">40' SILVERTON CONVERTIBLE DIESEL  - $105000 -</a><font size="-1"> (HOBE SOUND)</font> <span class="p"> pic</span></p>
EOD
    category_listing_one = <<EOD
<p><a href="/pbc/reb/1128661387.html">$2995000 / 5br - Downtown Boca New Home To Be Built -</a><font size="-1"> (Boca Raton)</font> <span class="p"> pic</span> &lt;&lt;<i><a href="/reb/">real&nbsp;estate - by broker</a></i></p>
EOD
    category_listing_two = <<EOD
<p><a href="/mdc/jwl/1128691192.html">925 Sterling Silver Dragonfly Charm Bracelet - $25 -</a> <span class="p"> img</span></p>
EOD

    empty_listing = CraigScrape::Listings.new # TODO: I think this isnt the way to go - we should make this a self.parse_summary kind of thing...

    one = CraigScrape::PostSummary.new empty_listing.parse_summary(Hpricot.parse(search_html_one).at('p'))
    assert_equal true, one.has_img?
    assert_equal false, one.has_pic?
    assert_equal true, one.has_pic_or_img?
    assert_equal '/brw/reb/1128608404.html', one.href
    assert_equal "Losing your house?  You'll need this New Loan Mod Video", one.label
    assert_equal "real\302\240estate - by broker", one.section
    assert_equal "W. Woodland", one.location
    assert_equal 4, one.date.month
    assert_equal 18, one.date.day
    assert_equal nil, one.price

    two = CraigScrape::PostSummary.new empty_listing.parse_summary(Hpricot.parse(search_html_two).at('p'))
    assert_equal true, two.has_img?
    assert_equal true, two.has_pic?
    assert_equal true, two.has_pic_or_img?
    assert_equal '/mdc/reb/1128609783.html', two.href
    assert_equal "$348000 / 1br - Large 1/1 plus office on 49th Floor. 5-Star NEW Condo. Great Views", two.label
    assert_equal "real\302\240estate - by broker", two.section
    assert_equal "Miami", two.location
    assert_equal 1, two.date.month
    assert_equal 4, two.date.day
    assert_equal 348000.0, two.price

    three = CraigScrape::PostSummary.new empty_listing.parse_summary(Hpricot.parse(search_html_three).at('p'))
    assert_equal false, three.has_img?
    assert_equal true, three.has_pic?
    assert_equal true, three.has_pic_or_img?
    assert_equal '/mdc/reb/1128520894.html', three.href
    assert_equal "$22,000 HOME -ADULT COMMUNITY BOYNTON BEACH", three.label
    assert_equal "real\302\240estate - by broker", three.section
    assert_equal nil, three.location
    assert_equal 12, three.date.month
    assert_equal 31, three.date.day
    assert_equal 22.0, three.price

    four = CraigScrape::PostSummary.new empty_listing.parse_summary(Hpricot.parse(search_html_four).at('p'))
    assert_equal false, four.has_img?
    assert_equal false, four.has_pic?
    assert_equal false, four.has_pic_or_img?
    assert_equal '/mdc/reb/1128474725.html', four.href
    assert_equal "$325000 / 3br - GOOD DEAL GREAT HOUSE AND LOCATION", four.label
    assert_equal "real\302\240estate - by broker", four.section
    assert_equal "CORAL GABLES", four.location
    assert_equal 7, four.date.month
    assert_equal 22, four.date.day
    assert_equal 325000.0, four.price

    five = CraigScrape::PostSummary.new empty_listing.parse_summary(Hpricot.parse(search_html_five).at('p'))
    assert_equal false, five.has_img?
    assert_equal true, five.has_pic?
    assert_equal true, five.has_pic_or_img?
    assert_equal '/pbc/boa/1115308178.html', five.href
    assert_equal "40' SILVERTON CONVERTIBLE DIESEL  - $105000", five.label
    assert_equal nil, five.section
    assert_equal "HOBE SOUND", five.location
    assert_equal 4, five.date.month
    assert_equal 9, five.date.day
    assert_equal 105000.0, five.price

    five = CraigScrape::PostSummary.new empty_listing.parse_summary(Hpricot.parse(category_listing_one).at('p'))
    assert_equal false, five.has_img?
    assert_equal true,  five.has_pic?
    assert_equal true, five.has_pic_or_img?
    assert_equal '/pbc/reb/1128661387.html', five.href
    assert_equal "$2995000 / 5br - Downtown Boca New Home To Be Built", five.label
    assert_equal "real\302\240estate - by broker", five.section
    assert_equal "Boca Raton", five.location
    assert_equal nil, five.date
    assert_equal 2995000.0, five.price

    six = CraigScrape::PostSummary.new empty_listing.parse_summary(Hpricot.parse(category_listing_two).at('p'))
    assert_equal true, six.has_img?
    assert_equal false,  six.has_pic?
    assert_equal true, six.has_pic_or_img?
    assert_equal '/mdc/jwl/1128691192.html', six.href
    assert_equal "925 Sterling Silver Dragonfly Charm Bracelet - $25", six.label
    assert_equal nil, six.section
    assert_equal nil, six.location
    assert_equal nil, six.date
    assert_equal 25.0, six.price
  end

  def test_listings_parse 
    category = CraigScrape::Listings.new relative_uri_for('listing_samples/category_output.html')
    assert_equal 'index100.html', category.next_page_href
    assert_equal 100, category.posts.length
    category.posts[0..80].each do |l|
      assert_equal 4, l.date.month
      assert_equal 18, l.date.day
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
    mia_fua_index8900_052109.posts[0..13].each do |l|
      assert_equal 5, l.date.month
      assert_equal 15, l.date.day
    end
    mia_fua_index8900_052109.posts[14..99].each do |l|
      assert_equal 5, l.date.month
      assert_equal 14, l.date.day
    end
    
    empty_listings = CraigScrape::Listings.new relative_uri_for('listing_samples/empty_listings.html')
    assert_equal nil, empty_listings.next_page_href
    assert_equal [], empty_listings.posts
    
  end
  
  def test_posting_parse
    posting0 = CraigScrape::PostFull.new relative_uri_for('post_samples/posting0.html')
    assert_equal "Has storage for videos/dvds. About 2 ft high by 21/2 ft widw. Almond/light beige color", posting0.contents
    assert_equal ["south florida craigslist", "miami / dade", "furniture - by owner"], posting0.full_section
    assert_equal "tv cart on wheels - $35 (NMB)", posting0.header
    assert_equal "tv cart on wheels", posting0.title
    assert_equal "NMB", posting0.location
    assert_equal 1131363612, posting0.posting_id
    assert_equal "sale-ktf9w-1131363612@craigslist.org", posting0.reply_to 
    assert_equal [0, 21, 13, 20, 4, 2009, 1, 110, true, "EDT"], posting0.post_time.to_a
    assert_equal [], posting0.images
    assert_equal "Has storage for videos/dvds. About 2 ft high by 21/2 ft widw. Almond/light beige color",posting0.contents_as_plain
    assert_equal 35.0, posting0.price
    
    posting1 = CraigScrape::PostFull.new relative_uri_for('post_samples/posting1.html')
    assert_equal "Residential income property\227Investors this property is for you! This duplex has a 2bedroom/1bath unit on each side. It features updated kitchens and baths (new tubs, toilet, sink, vanities), ceramic tile flooring throughout, separate water and electric meters and on site laundry facilities. It is also closed to the Galleria, beaches and downtown Fort Lauderdale! \r<br />\n\r<br />\nJe parle le Fran\347ais\r<br />\n\r<br />\nThis property is being offered by Blaunch Perrier, Broker Associate, Atlantic Properties International. Blaunch can be reached at 954-593-0077. For additional property information you may also visit www.garylanham.com\r<br />\n\r<br />", posting1.contents
    assert_equal ["south florida craigslist", "broward county", "real estate - by broker"], posting1.full_section
    assert_equal "$189900 / 4br - Investment Property--Duplex in Fort Lauderdale", posting1.header
    assert_equal "Investment Property--Duplex in Fort Lauderdale", posting1.title
    assert_equal '1000 NE 14th Pl', posting1.location
    assert_equal 1131242195, posting1.posting_id
    assert_equal "hous-5nzhq-1131242195@craigslist.org", posting1.reply_to 
    assert_equal [0, 33, 13, 20, 4, 2009, 1, 110, true, "EDT"], posting1.post_time.to_a
    assert_equal %w(http://images.craigslist.org/3n83o33l5ZZZZZZZZZ94k913ac1582d4b1fa4.jpg http://images.craigslist.org/3n93p63obZZZZZZZZZ94k19d5e32eb3b610c2.jpg http://images.craigslist.org/3n93m03l6ZZZZZZZZZ94k6e9785e37a1b1f3f.jpg http://images.craigslist.org/3ma3oc3l4ZZZZZZZZZ94kbfecbcd2fb2e19cc.jpg), posting1.images
    assert_equal "Residential income property\227Investors this property is for you! This duplex has a 2bedroom/1bath unit on each side. It features updated kitchens and baths (new tubs, toilet, sink, vanities), ceramic tile flooring throughout, separate water and electric meters and on site laundry facilities. It is also closed to the Galleria, beaches and downtown Fort Lauderdale! \r\n\r\nJe parle le Fran\347ais\r\n\r\nThis property is being offered by Blaunch Perrier, Broker Associate, Atlantic Properties International. Blaunch can be reached at 954-593-0077. For additional property information you may also visit www.garylanham.com\r\n\r", posting1.contents_as_plain
    assert_equal 189900.0, posting1.price

    posting2 = CraigScrape::PostFull.new relative_uri_for('post_samples/posting2.html')
    assert_equal 15775, posting2.contents.length # This is easy, and probably fine enough
    assert_equal ["south florida craigslist", "broward county", "cars & trucks - by dealer"], posting2.full_section
    assert_equal "PRESENTING A ELECTRON BLUE METALLIC 2002 CHEVROLET CORVETTE Z06 6 SPEE - $23975 (Fort Lauderdale)", posting2.header
    assert_equal "PRESENTING A ELECTRON BLUE METALLIC 2002 CHEVROLET CORVETTE Z06 6 SPEE", posting2.title
    assert_equal 'Fort Lauderdale', posting2.location
    assert_equal 1127037648, posting2.posting_id
    assert_equal nil, posting2.reply_to 
    assert_equal [0, 16, 14, 17, 4, 2009, 5, 107, true, "EDT"], posting2.post_time.to_a
    assert_equal [], posting2.images
    assert_equal "\302\240 Sheehan Buick Pontiac GMC \302\240 Pompano Beach, FL(754) 224-3257 \302\240PRESENTING A ELECTRON BLUE METALLIC 2002 CHEVROLET CORVETTE Z06 6 SPEED FLORIDA DRIVEN SMOKIN' SPORTS CAR!2002 Chevrolet Corvette Z06 Florida Driven AutoCheck Certified 5.7L V8 6sp2 Door Coupe.\302\240Price: \302\240 $23,975Exterior:Electron Blue MetallicInterior:BlackStock#:P5110AVIN:1G1YY12S625129021FREE AutoCheck Vehicle ReportMileage:63,560Transmission:6 Speed ManualEngine:V8 5.7L OHVWarranty:Limited WarrantyTitle:Clear\302\273\302\240View All 58 Photos\302\273\302\240View Full Vehicle Details\302\273\302\240Ask the Seller a Question\302\273\302\240E-mail this to a Friend\302\240 DescriptionPRESENTING A ELECTRON BLUE METALLIC 2002 CHEVROLET CORVETTE Z06 6 SPEED FLORIDA DRIVEN SMOKIN' SPORTS CAR!\r\n\r\nLOADED WITH BLACK LEATHER BUCKET SEATS, POWER DRIVERS SEAT, DUAL ZONE CLIMATE CONTROL, 4 WHEEL ABS BRAKES, POWER STEERING AND BRAKES, REAR LIMITED SLIP DIFFERENTIAL, STABILITY CONTROL, CRUISE CONTROL, TLT STEERING WHEEL, POWER WINDOWS AND LOCKS, AUTOMATIC ON/OFF HEADLAMPS, FOG LIGHTS, DUAL AIR BAG SAFETY, AM/FM STEREO CD PLAYER, INTERMITTENT WINDSHIELD WIPERS AND SO MUCH MORE - THIS CAR IS TOTALLY HOT WITH GREAT LOW MILES!\r\n\r\nPlease call us to make your deal now at 1-888-453-5244. Please visit our Website at www.sheehanautoplex.com ***View 50+ Pictures of this vehicle - a complete description including standard features and all added options & a FREE AUTO CHECK REPORT at www.sheehanautoplex.com. ***Financing for Everyone - Good credit - bad credit - divorce - charge off's - NO PROBLEM. To complete a secure credit application, please visit our website at www.sheehanautoplex.com ***The largest Dealer in the State of Florida - We export all over the world - For details please visit www.sheehanautoplex.com ***Sheehan Autoplex takes great pride in our outstanding customer service and has been recognized by the following associations - BBB (Better Business Bureau) - NIADA - and the FIADA. Call us to get your best deal. CALL NOW. 1-888-453-5244\302\240 Contact Sheehan Buick Pontiac GMCPhone:(754) 224-3257Fax:(954) 781-9050Phone:(754) 224-3257E-mail:sales@proauto.comBusiness HoursWeekdays:9:00 AM to 9:00 PMSat:9:00 AM to 6:00 PMSun:",posting2.contents_as_plain
    assert_equal 23975.0, posting2.price

    posting3 = CraigScrape::PostFull.new relative_uri_for('post_samples/posting3.html')
    assert_equal "1992 Twin Turbo 300ZX. This car is pearl white outside and Camel leather interior with suede accents. Motor was re-done from the ground up two years ago. 23,000 on new motor rebuild! New Leather seats and center arm rest done also two years ago. Has Alpine Am/Fm Cd with Ipod cable, Viper pager alarm New! JL Audio Amp & JLAudio sub box custom made. Mtx mids& highs component speakers sparate tweeter. Car runs strong & straight. Just detailed the interior. Exterior should be painted. This car once painted will sell for over $10,000. \r<br />\nCome get a great deal now! offers and trades will be considered. 786-303-6550 Manny", posting3.contents
    assert_equal ["south florida craigslist", "miami / dade", "cars & trucks - by owner"], posting3.full_section
    assert_equal "300ZX Nissan Twin Turbo 1992 - $5800 (N.Miami/ Hialeah)", posting3.header
    assert_equal "300ZX Nissan Twin Turbo 1992", posting3.title
    assert_equal "N.Miami/ Hialeah", posting3.location
    assert_equal 1130212403, posting3.posting_id
    assert_equal "sale-c9bpa-1130212403@craigslist.org", posting3.reply_to 
    assert_equal [0, 21, 18, 19, 4, 2009, 0, 109, true, "EDT"], posting3.post_time.to_a
    assert_equal %w(http://images.craigslist.org/3n23kf3lfZZZZZZZZZ94j1160e7d7b0601934.jpg http://images.craigslist.org/3nc3kf3p2ZZZZZZZZZ94j04fbc71e0a551ace.jpg http://images.craigslist.org/3nc3k33l7ZZZZZZZZZ94k13d8d7b1024e1e0e.jpg http://images.craigslist.org/3n23k63mfZZZZZZZZZ94k7838ae5d48d91eb8.jpg), posting3.images
    assert_equal "1992 Twin Turbo 300ZX. This car is pearl white outside and Camel leather interior with suede accents. Motor was re-done from the ground up two years ago. 23,000 on new motor rebuild! New Leather seats and center arm rest done also two years ago. Has Alpine Am/Fm Cd with Ipod cable, Viper pager alarm New! JL Audio Amp & JLAudio sub box custom made. Mtx mids& highs component speakers sparate tweeter. Car runs strong & straight. Just detailed the interior. Exterior should be painted. This car once painted will sell for over $10,000. \r\nCome get a great deal now! offers and trades will be considered. 786-303-6550 Manny",posting3.contents_as_plain
    assert_equal 5800.0, posting3.price

    # This one ended up being quite a curveball since the user uploaded HTML was such junk:
    posting4 = CraigScrape::PostFull.new relative_uri_for('post_samples/posting4.html')
    assert_equal 20640, posting4.contents.length
    assert_equal ["south florida craigslist", "broward county", "real estate - by broker"], posting4.full_section
    assert_equal "$225000 / 3br - Palm Aire Golf Corner Unit!", posting4.header
    assert_equal "Palm Aire Golf Corner Unit!", posting4.title
    assert_equal nil, posting4.location
    assert_equal 1139303170, posting4.posting_id
    assert_equal "hous-sk9f2-1139303170@craigslist.org", posting4.reply_to 
    assert_equal [0, 8, 9, 25, 4, 2009, 6, 115, true, "EDT"], posting4.post_time.to_a
    assert_equal [], posting4.images
    assert_equal 6399,posting4.contents_as_plain.length
    assert_equal 225000.0, posting4.price
    
    posting5 = CraigScrape::PostFull.new relative_uri_for('post_samples/posting5.html')
    assert_equal true, posting5.flagged_for_removal?
    assert_equal nil, posting5.contents
    assert_equal ["south florida craigslist", "palm beach co", "apts/housing for rent"], posting5.full_section
    assert_equal "This posting has been <a href=\"http://www.craigslist.org/about/help/flags_and_community_moderation\">flagged</a> for removal", posting5.header
    assert_equal nil, posting5.title
    assert_equal nil, posting5.location
    assert_equal nil, posting5.posting_id
    assert_equal nil, posting5.reply_to 
    assert_equal nil, posting5.post_time
    assert_equal [],  posting5.images
    assert_equal nil, posting5.contents_as_plain
    assert_equal nil, posting5.price
    
    posting_deleted = CraigScrape::PostFull.new relative_uri_for('post_samples/this_post_has_been_deleted_by_its_author.html')
    assert_equal true, posting_deleted.deleted_by_author?
    assert_equal nil, posting_deleted.contents
    assert_equal ["south florida craigslist", "broward county", "cars & trucks - by owner"], posting_deleted.full_section
    assert_equal "This posting has been deleted by its author.", posting_deleted.header
    assert_equal nil, posting_deleted.title
    assert_equal nil, posting_deleted.location
    assert_equal nil, posting_deleted.posting_id
    assert_equal nil, posting_deleted.reply_to 
    assert_equal nil, posting_deleted.post_time
    assert_equal [],  posting_deleted.images
    assert_equal nil, posting_deleted.contents_as_plain
    assert_equal nil, posting_deleted.price

    posting6 = CraigScrape::PostFull.new relative_uri_for('post_samples/1207457727.html')
    assert_equal "<p><br />Call!! asking for a new owner.<br />  no deposit required rent to own properties. <br /> <br /> Defaulting payment records are not a problem, <br /> we will help you protect the previous owners credit history! 202-567-6371  <br /><br /></p>",posting6.contents
    assert_equal "Call!! asking for a new owner.  no deposit required rent to own properties.   Defaulting payment records are not a problem,  we will help you protect the previous owners credit history! 202-567-6371  ",posting6.contents_as_plain
    assert_equal false,posting6.deleted_by_author?
    assert_equal false,posting6.flagged_for_removal?
    assert_equal ["south florida craigslist", "broward county", "apts/housing for rent"],posting6.full_section
    assert_equal "$1350 / 3br - 2bth for no deposit req (Coral Springs)",posting6.header
    assert_equal ["http://images.craigslist.org/3k43pe3o8ZZZZZZZZZ9655022102a3ea51624.jpg", "http://images.craigslist.org/3n13m53p6ZZZZZZZZZ96596515e51237a179c.jpg", "http://images.craigslist.org/3od3p33leZZZZZZZZZ9656d614da8e3a51dd9.jpg", "http://images.craigslist.org/3pb3oa3leZZZZZZZZZ965eb60e4d2344019fb.jpg"],posting6.images
    assert_equal 'Coral Springs',posting6.location
    assert_equal [0, 56, 18, 5, 6, 2009, 5, 156, true, "EDT"],posting6.post_time.to_a
    assert_equal 1207457727,posting6.posting_id
    assert_equal 1350.0,posting6.price
    assert_equal "hous-ccpap-1207457727@craigslist.org",posting6.reply_to
    assert_equal "2bth for no deposit req",posting6.title    
  end

  private
  
  def read_as_hpricot(test_file)
    Hpricot.parse(
      File.open('%s/%s' % [File.dirname(__FILE__), test_file]).read
    )
  end
  
  def relative_uri_for(filename)
    'file://%s/%s' % [File.dirname(File.expand_path(__FILE__)), filename]
  end
  
  def pp_assertions(obj, obj_name)
    probable_accessors = (obj.methods-obj.class.superclass.methods)
    
    puts
    probable_accessors.sort.each do |m|
      val = obj.send(m.to_sym)
      
      # There's a good number of transformations worth doing here, I'll just start like this for now:
      if val.kind_of? Time
        # I've decided this is the the easiest way to understand and test a time
        val = val.to_a
        m = "#{m}.to_a"
      end
      
      puts "assert_equal %s, %s.%s" % [val.inspect,obj_name,m]
    end    
  end
end