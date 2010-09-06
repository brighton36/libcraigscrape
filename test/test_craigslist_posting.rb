#!/usr/bin/ruby

require 'test/unit'
require File.dirname(__FILE__)+'/../lib/libcraigscrape'
require File.dirname(__FILE__)+'/libcraigscrape_test_helpers'


class CraigslistPostingTest < Test::Unit::TestCase
  include LibcraigscrapeTestHelpers
  
  def test_pukes
    assert_raise(CraigScrape::Scraper::ParseError) do
      CraigScrape::Posting.new( relative_uri_for('google.html') ).contents
    end
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

    one = CraigScrape::Posting.new CraigScrape::Listings.parse_summary(Hpricot.parse(search_html_one).at('p'))
    assert_equal true, one.has_img?
    assert_equal false, one.has_pic?
    assert_equal true, one.has_pic_or_img?
    assert_equal '/brw/reb/1128608404.html', one.href
    assert_equal "Losing your house?  You'll need this New Loan Mod Video", one.label
    assert_equal "real estate - by broker", one.section
    assert_equal "W. Woodland", one.location
    assert_equal 4, one.post_date.month
    assert_equal 18, one.post_date.day
    assert_equal nil, one.price

    two = CraigScrape::Posting.new CraigScrape::Listings.parse_summary(Hpricot.parse(search_html_two).at('p'))
    assert_equal true, two.has_img?
    assert_equal true, two.has_pic?
    assert_equal true, two.has_pic_or_img?
    assert_equal '/mdc/reb/1128609783.html', two.href
    assert_equal "$348000 / 1br - Large 1/1 plus office on 49th Floor. 5-Star NEW Condo. Great Views", two.label
    assert_equal "real estate - by broker", two.section
    assert_equal "Miami", two.location
    assert_equal 1, two.post_date.month
    assert_equal 4, two.post_date.day
    assert_equal 348000.0, two.price

    three = CraigScrape::Posting.new CraigScrape::Listings.parse_summary(Hpricot.parse(search_html_three).at('p'))
    assert_equal false, three.has_img?
    assert_equal true, three.has_pic?
    assert_equal true, three.has_pic_or_img?
    assert_equal '/mdc/reb/1128520894.html', three.href
    assert_equal "$22,000 HOME -ADULT COMMUNITY BOYNTON BEACH", three.label
    assert_equal "real estate - by broker", three.section
    assert_equal nil, three.location
    assert_equal 12, three.post_date.month
    assert_equal 31, three.post_date.day
    assert_equal 22.0, three.price

    four = CraigScrape::Posting.new CraigScrape::Listings.parse_summary(Hpricot.parse(search_html_four).at('p'))
    assert_equal false, four.has_img?
    assert_equal false, four.has_pic?
    assert_equal false, four.has_pic_or_img?
    assert_equal '/mdc/reb/1128474725.html', four.href
    assert_equal "$325000 / 3br - GOOD DEAL GREAT HOUSE AND LOCATION", four.label
    assert_equal "real estate - by broker", four.section
    assert_equal "CORAL GABLES", four.location
    assert_equal 7, four.post_date.month
    assert_equal 22, four.post_date.day
    assert_equal 325000.0, four.price

    five = CraigScrape::Posting.new CraigScrape::Listings.parse_summary(Hpricot.parse(search_html_five).at('p'))
    assert_equal false, five.has_img?
    assert_equal true, five.has_pic?
    assert_equal true, five.has_pic_or_img?
    assert_equal '/pbc/boa/1115308178.html', five.href
    assert_equal "40' SILVERTON CONVERTIBLE DIESEL  - $105000", five.label
    assert_equal nil, five.section
    assert_equal "HOBE SOUND", five.location
    assert_equal 4, five.post_date.month
    assert_equal 9, five.post_date.day
    assert_equal 105000.0, five.price

    five = CraigScrape::Posting.new CraigScrape::Listings.parse_summary(Hpricot.parse(category_listing_one).at('p'))
    assert_equal false, five.has_img?
    assert_equal true,  five.has_pic?
    assert_equal true, five.has_pic_or_img?
    assert_equal '/pbc/reb/1128661387.html', five.href
    assert_equal "$2995000 / 5br - Downtown Boca New Home To Be Built", five.label
    assert_equal "real estate - by broker", five.section
    assert_equal "Boca Raton", five.location
    assert_equal nil, five.post_date
    assert_equal 2995000.0, five.price

    six = CraigScrape::Posting.new CraigScrape::Listings.parse_summary(Hpricot.parse(category_listing_two).at('p'))
    assert_equal true, six.has_img?
    assert_equal false,  six.has_pic?
    assert_equal true, six.has_pic_or_img?
    assert_equal '/mdc/jwl/1128691192.html', six.href
    assert_equal "925 Sterling Silver Dragonfly Charm Bracelet - $25", six.label
    assert_equal nil, six.section
    assert_equal nil, six.location
    assert_equal nil, six.post_date
    assert_equal 25.0, six.price
  end
  

  def test_posting_parse
    posting0 = CraigScrape::Posting.new relative_uri_for('post_samples/posting0.html')
    assert_equal "Has storage for videos/dvds. About 2 ft high by 21/2 ft widw. Almond/light beige color", posting0.contents
    assert_equal ["south florida craigslist", "miami / dade", "furniture - by owner"], posting0.full_section
    assert_equal "tv cart on wheels - $35 (NMB)", posting0.header
    assert_equal "tv cart on wheels - $35", posting0.label
    assert_equal "tv cart on wheels", posting0.title
    assert_equal "NMB", posting0.location
    assert_equal 1131363612, posting0.posting_id
    assert_equal "sale-ktf9w-1131363612@craigslist.org", posting0.reply_to 
    assert_equal [0, 21, 13, 20, 4, 2009, 1, 110, true, "EDT"], posting0.post_time.to_a
    assert_equal [], posting0.pics
    assert_equal "Has storage for videos/dvds. About 2 ft high by 21/2 ft widw. Almond/light beige color",posting0.contents_as_plain
    assert_equal 35.0, posting0.price
    assert_equal [], posting0.images
    assert_equal [], posting0.img_types
    
    posting1 = CraigScrape::Posting.new relative_uri_for('post_samples/posting1.html')
    assert_equal "Residential income property\227Investors this property is for you! This duplex has a 2bedroom/1bath unit on each side. It features updated kitchens and baths (new tubs, toilet, sink, vanities), ceramic tile flooring throughout, separate water and electric meters and on site laundry facilities. It is also closed to the Galleria, beaches and downtown Fort Lauderdale! \r<br>\n\r<br>\nJe parle le Fran\347ais\r<br>\n\r<br>\nThis property is being offered by Blaunch Perrier, Broker Associate, Atlantic Properties International. Blaunch can be reached at 954-593-0077. For additional property information you may also visit www.garylanham.com\r<br>\n\r<br>", posting1.contents
    assert_equal ["south florida craigslist", "broward county", "real estate - by broker"], posting1.full_section
    assert_equal "$189900 / 4br - Investment Property--Duplex in Fort Lauderdale", posting1.header
    assert_equal "$189900 / 4br - Investment Property--Duplex in Fort Lauderdale", posting1.label
    assert_equal "Investment Property--Duplex in Fort Lauderdale", posting1.title
    assert_equal '1000 NE 14th Pl', posting1.location
    assert_equal 1131242195, posting1.posting_id
    assert_equal "hous-5nzhq-1131242195@craigslist.org", posting1.reply_to 
    assert_equal [0, 33, 13, 20, 4, 2009, 1, 110, true, "EDT"], posting1.post_time.to_a
    assert_equal %w(http://images.craigslist.org/3n83o33l5ZZZZZZZZZ94k913ac1582d4b1fa4.jpg http://images.craigslist.org/3n93p63obZZZZZZZZZ94k19d5e32eb3b610c2.jpg http://images.craigslist.org/3n93m03l6ZZZZZZZZZ94k6e9785e37a1b1f3f.jpg http://images.craigslist.org/3ma3oc3l4ZZZZZZZZZ94kbfecbcd2fb2e19cc.jpg), posting1.pics
    assert_equal "Residential income property\227Investors this property is for you! This duplex has a 2bedroom/1bath unit on each side. It features updated kitchens and baths (new tubs, toilet, sink, vanities), ceramic tile flooring throughout, separate water and electric meters and on site laundry facilities. It is also closed to the Galleria, beaches and downtown Fort Lauderdale! \r\n\r\nJe parle le Fran\347ais\r\n\r\nThis property is being offered by Blaunch Perrier, Broker Associate, Atlantic Properties International. Blaunch can be reached at 954-593-0077. For additional property information you may also visit www.garylanham.com\r\n\r", posting1.contents_as_plain
    assert_equal 189900.0, posting1.price
    assert_equal [], posting1.images
    assert_equal ["http://images.craigslist.org/3n83o33l5ZZZZZZZZZ94k913ac1582d4b1fa4.jpg", "http://images.craigslist.org/3n93p63obZZZZZZZZZ94k19d5e32eb3b610c2.jpg", "http://images.craigslist.org/3n93m03l6ZZZZZZZZZ94k6e9785e37a1b1f3f.jpg", "http://images.craigslist.org/3ma3oc3l4ZZZZZZZZZ94kbfecbcd2fb2e19cc.jpg"], posting1.pics
    assert_equal [:pic], posting1.img_types

    posting2 = CraigScrape::Posting.new relative_uri_for('post_samples/posting2.html')
    assert_equal 15488, posting2.contents.length # This is easy, and probably fine enough
    assert_equal ["south florida craigslist", "broward county", "cars & trucks - by dealer"], posting2.full_section
    assert_equal "PRESENTING A ELECTRON BLUE METALLIC 2002 CHEVROLET CORVETTE Z06 6 SPEE - $23975 (Fort Lauderdale)", posting2.header
    assert_equal "PRESENTING A ELECTRON BLUE METALLIC 2002 CHEVROLET CORVETTE Z06 6 SPEE - $23975", posting2.label
    assert_equal "PRESENTING A ELECTRON BLUE METALLIC 2002 CHEVROLET CORVETTE Z06 6 SPEE", posting2.title
    assert_equal 'Fort Lauderdale', posting2.location
    assert_equal 1127037648, posting2.posting_id
    assert_equal nil, posting2.reply_to 
    assert_equal [0, 16, 14, 17, 4, 2009, 5, 107, true, "EDT"], posting2.post_time.to_a
    assert_equal [], posting2.pics
    assert_equal "\302\240 Sheehan Buick Pontiac GMC \302\240 Pompano Beach, FL(754) 224-3257 \302\240PRESENTING A ELECTRON BLUE METALLIC 2002 CHEVROLET CORVETTE Z06 6 SPEED FLORIDA DRIVEN SMOKIN' SPORTS CAR!2002 Chevrolet Corvette Z06 Florida Driven AutoCheck Certified 5.7L V8 6sp2 Door Coupe.\302\240Price: \302\240 $23,975Exterior:Electron Blue MetallicInterior:BlackStock#:P5110AVIN:1G1YY12S625129021FREE AutoCheck Vehicle ReportMileage:63,560Transmission:6 Speed ManualEngine:V8 5.7L OHVWarranty:Limited WarrantyTitle:Clear\302\273\302\240View All 58 Photos\302\273\302\240View Full Vehicle Details\302\273\302\240Ask the Seller a Question\302\273\302\240E-mail this to a Friend\302\240 DescriptionPRESENTING A ELECTRON BLUE METALLIC 2002 CHEVROLET CORVETTE Z06 6 SPEED FLORIDA DRIVEN SMOKIN' SPORTS CAR!\r\n\r\nLOADED WITH BLACK LEATHER BUCKET SEATS, POWER DRIVERS SEAT, DUAL ZONE CLIMATE CONTROL, 4 WHEEL ABS BRAKES, POWER STEERING AND BRAKES, REAR LIMITED SLIP DIFFERENTIAL, STABILITY CONTROL, CRUISE CONTROL, TLT STEERING WHEEL, POWER WINDOWS AND LOCKS, AUTOMATIC ON/OFF HEADLAMPS, FOG LIGHTS, DUAL AIR BAG SAFETY, AM/FM STEREO CD PLAYER, INTERMITTENT WINDSHIELD WIPERS AND SO MUCH MORE - THIS CAR IS TOTALLY HOT WITH GREAT LOW MILES!\r\n\r\nPlease call us to make your deal now at 1-888-453-5244. Please visit our Website at www.sheehanautoplex.com ***View 50+ Pictures of this vehicle - a complete description including standard features and all added options & a FREE AUTO CHECK REPORT at www.sheehanautoplex.com. ***Financing for Everyone - Good credit - bad credit - divorce - charge off's - NO PROBLEM. To complete a secure credit application, please visit our website at www.sheehanautoplex.com ***The largest Dealer in the State of Florida - We export all over the world - For details please visit www.sheehanautoplex.com ***Sheehan Autoplex takes great pride in our outstanding customer service and has been recognized by the following associations - BBB (Better Business Bureau) - NIADA - and the FIADA. Call us to get your best deal. CALL NOW. 1-888-453-5244\302\240 Contact Sheehan Buick Pontiac GMCPhone:(754) 224-3257Fax:(954) 781-9050Phone:(754) 224-3257E-mail:sales@proauto.comBusiness HoursWeekdays:9:00 AM to 9:00 PMSat:9:00 AM to 6:00 PMSun:",posting2.contents_as_plain
    assert_equal 23975.0, posting2.price
    assert_equal ["http://static.automanager.com/c/012569/723b2925-b81d-4d6c-8e15-1542bab88dc1/19bce8e86c_355.jpg", "http://static.automanager.com/c/012569/723b2925-b81d-4d6c-8e15-1542bab88dc1/ff9b026b06_355.jpg", "http://static.automanager.com/c/012569/723b2925-b81d-4d6c-8e15-1542bab88dc1/6b75d87620_355.jpg", "http://static.automanager.com/c/012569/723b2925-b81d-4d6c-8e15-1542bab88dc1/53b025e472_355.jpg", "http://static.automanager.com/c/012569/723b2925-b81d-4d6c-8e15-1542bab88dc1/0d1befded7_105.jpg", "http://static.automanager.com/c/012569/723b2925-b81d-4d6c-8e15-1542bab88dc1/95477f92bb_105.jpg", "http://static.automanager.com/c/012569/723b2925-b81d-4d6c-8e15-1542bab88dc1/2850b2f160_105.jpg", "http://static.automanager.com/c/012569/723b2925-b81d-4d6c-8e15-1542bab88dc1/a4281c6c91_105.jpg", "http://static.automanager.com/c/012569/723b2925-b81d-4d6c-8e15-1542bab88dc1/862ee4ce71_105.jpg", "http://static.automanager.com/c/012569/723b2925-b81d-4d6c-8e15-1542bab88dc1/74cadeff2e_105.jpg", "http://static.automanager.com/c/012569/723b2925-b81d-4d6c-8e15-1542bab88dc1/63b05a0c76_105.jpg", "http://static.automanager.com/c/012569/723b2925-b81d-4d6c-8e15-1542bab88dc1/00f84ea5bf_105.jpg", "http://static.automanager.com/c/012569/723b2925-b81d-4d6c-8e15-1542bab88dc1/fe29734ab5_105.jpg", "http://static.automanager.com/c/012569/723b2925-b81d-4d6c-8e15-1542bab88dc1/7f714d5159_105.jpg", "http://static.automanager.com/c/012569/723b2925-b81d-4d6c-8e15-1542bab88dc1/720ddcc0a1_105.jpg", "http://static.automanager.com/c/012569/723b2925-b81d-4d6c-8e15-1542bab88dc1/fc90fba588_105.jpg", "http://static.automanager.com/c/012569/723b2925-b81d-4d6c-8e15-1542bab88dc1/d576661767_105.jpg", "http://static.automanager.com/c/012569/723b2925-b81d-4d6c-8e15-1542bab88dc1/3423fb4814_105.jpg", "http://static.automanager.com/c/012569/723b2925-b81d-4d6c-8e15-1542bab88dc1/5f0a0e85f8_105.jpg", "http://static.automanager.com/c/012569/723b2925-b81d-4d6c-8e15-1542bab88dc1/d3ca0e29cc_105.jpg", "http://static.automanager.com/c/012569/723b2925-b81d-4d6c-8e15-1542bab88dc1/23888ae8bc_105.jpg", "http://static.automanager.com/c/012569/723b2925-b81d-4d6c-8e15-1542bab88dc1/93fc7d2373_105.jpg", "http://static.automanager.com/c/012569/723b2925-b81d-4d6c-8e15-1542bab88dc1/9ac9da47b8_105.jpg", "http://static.automanager.com/c/012569/723b2925-b81d-4d6c-8e15-1542bab88dc1/b1a84ca79e_105.jpg", "http://static.automanager.com/c/012569/723b2925-b81d-4d6c-8e15-1542bab88dc1/6d219b534d_105.jpg", "http://static.automanager.com/c/012569/723b2925-b81d-4d6c-8e15-1542bab88dc1/8bfe03d99b_105.jpg", "http://static.automanager.com/c/012569/723b2925-b81d-4d6c-8e15-1542bab88dc1/d1086ab561_105.jpg", "http://static.automanager.com/c/012569/723b2925-b81d-4d6c-8e15-1542bab88dc1/ab7a050466_105.jpg", "http://static.automanager.com/c/012569/723b2925-b81d-4d6c-8e15-1542bab88dc1/9ea616d5d7_105.jpg", "http://static.automanager.com/c/012569/723b2925-b81d-4d6c-8e15-1542bab88dc1/4b91de556d_105.jpg", "http://static.automanager.com/c/012569/723b2925-b81d-4d6c-8e15-1542bab88dc1/1cefd8873a_105.jpg", "http://static.automanager.com/c/012569/723b2925-b81d-4d6c-8e15-1542bab88dc1/8aec930e90_105.jpg", "http://static.automanager.com/c/012569/723b2925-b81d-4d6c-8e15-1542bab88dc1/76b603822f_105.jpg", "http://static.automanager.com/c/012569/723b2925-b81d-4d6c-8e15-1542bab88dc1/2d1b6d8a13_105.jpg", "http://static.automanager.com/c/012569/723b2925-b81d-4d6c-8e15-1542bab88dc1/4fc82180ab_105.jpg", "http://static.automanager.com/c/012569/723b2925-b81d-4d6c-8e15-1542bab88dc1/843c9e41ae_105.jpg", "http://static.automanager.com/c/012569/723b2925-b81d-4d6c-8e15-1542bab88dc1/9d91990245_105.jpg", "http://static.automanager.com/c/012569/723b2925-b81d-4d6c-8e15-1542bab88dc1/f34b8cfaed_105.jpg", "http://static.automanager.com/c/012569/723b2925-b81d-4d6c-8e15-1542bab88dc1/765dae1031_105.jpg", "http://static.automanager.com/c/012569/723b2925-b81d-4d6c-8e15-1542bab88dc1/7463a88d92_105.jpg", "http://static.automanager.com/c/012569/723b2925-b81d-4d6c-8e15-1542bab88dc1/afe5801857_105.jpg", "http://static.automanager.com/c/012569/723b2925-b81d-4d6c-8e15-1542bab88dc1/25abb2bd26_105.jpg", "http://static.automanager.com/c/012569/723b2925-b81d-4d6c-8e15-1542bab88dc1/bc2fdaa3ea_105.jpg", "http://static.automanager.com/c/012569/723b2925-b81d-4d6c-8e15-1542bab88dc1/e2a9b0dc69_105.jpg", "http://static.automanager.com/c/012569/723b2925-b81d-4d6c-8e15-1542bab88dc1/08c2ca66b6_105.jpg", "http://static.automanager.com/c/012569/723b2925-b81d-4d6c-8e15-1542bab88dc1/5e46230ec6_105.jpg", "http://static.automanager.com/c/012569/723b2925-b81d-4d6c-8e15-1542bab88dc1/0b45184c58_105.jpg", "http://static.automanager.com/c/012569/723b2925-b81d-4d6c-8e15-1542bab88dc1/311457aed0_105.jpg", "http://static.automanager.com/c/012569/723b2925-b81d-4d6c-8e15-1542bab88dc1/43090899dc_105.jpg", "http://static.automanager.com/c/012569/723b2925-b81d-4d6c-8e15-1542bab88dc1/c33b7f4c2a_105.jpg", "http://static.automanager.com/c/012569/723b2925-b81d-4d6c-8e15-1542bab88dc1/24f419b851_105.jpg", "http://static.automanager.com/c/012569/723b2925-b81d-4d6c-8e15-1542bab88dc1/50d3e2126d_105.jpg", "http://static.automanager.com/c/012569/723b2925-b81d-4d6c-8e15-1542bab88dc1/6c125ffc51_105.jpg", "http://static.automanager.com/c/012569/723b2925-b81d-4d6c-8e15-1542bab88dc1/93db0546fd_105.jpg", "http://static.automanager.com/c/012569/723b2925-b81d-4d6c-8e15-1542bab88dc1/00e0d91652_105.jpg", "http://static.automanager.com/c/012569/723b2925-b81d-4d6c-8e15-1542bab88dc1/2b242fbc58_105.jpg", "http://static.automanager.com/c/012569/723b2925-b81d-4d6c-8e15-1542bab88dc1/8ee3c932a2_105.jpg", "http://static.automanager.com/c/012569/723b2925-b81d-4d6c-8e15-1542bab88dc1/64103fe7bd_105.jpg"], posting2.images
    assert_equal [:img], posting2.img_types

    posting3 = CraigScrape::Posting.new relative_uri_for('post_samples/posting3.html')
    assert_equal "1992 Twin Turbo 300ZX. This car is pearl white outside and Camel leather interior with suede accents. Motor was re-done from the ground up two years ago. 23,000 on new motor rebuild! New Leather seats and center arm rest done also two years ago. Has Alpine Am/Fm Cd with Ipod cable, Viper pager alarm New! JL Audio Amp & JLAudio sub box custom made. Mtx mids& highs component speakers sparate tweeter. Car runs strong & straight. Just detailed the interior. Exterior should be painted. This car once painted will sell for over $10,000. \r<br>\nCome get a great deal now! offers and trades will be considered. 786-303-6550 Manny", posting3.contents
    assert_equal ["south florida craigslist", "miami / dade", "cars & trucks - by owner"], posting3.full_section
    assert_equal "300ZX Nissan Twin Turbo 1992 - $5800 (N.Miami/ Hialeah)", posting3.header
    assert_equal "300ZX Nissan Twin Turbo 1992 - $5800", posting3.label
    assert_equal "300ZX Nissan Twin Turbo 1992", posting3.title
    assert_equal "N.Miami/ Hialeah", posting3.location
    assert_equal 1130212403, posting3.posting_id
    assert_equal "sale-c9bpa-1130212403@craigslist.org", posting3.reply_to 
    assert_equal [0, 21, 18, 19, 4, 2009, 0, 109, true, "EDT"], posting3.post_time.to_a
    assert_equal %w(http://images.craigslist.org/3n23kf3lfZZZZZZZZZ94j1160e7d7b0601934.jpg http://images.craigslist.org/3nc3kf3p2ZZZZZZZZZ94j04fbc71e0a551ace.jpg http://images.craigslist.org/3nc3k33l7ZZZZZZZZZ94k13d8d7b1024e1e0e.jpg http://images.craigslist.org/3n23k63mfZZZZZZZZZ94k7838ae5d48d91eb8.jpg), posting3.pics
    assert_equal "1992 Twin Turbo 300ZX. This car is pearl white outside and Camel leather interior with suede accents. Motor was re-done from the ground up two years ago. 23,000 on new motor rebuild! New Leather seats and center arm rest done also two years ago. Has Alpine Am/Fm Cd with Ipod cable, Viper pager alarm New! JL Audio Amp & JLAudio sub box custom made. Mtx mids& highs component speakers sparate tweeter. Car runs strong & straight. Just detailed the interior. Exterior should be painted. This car once painted will sell for over $10,000. \r\nCome get a great deal now! offers and trades will be considered. 786-303-6550 Manny",posting3.contents_as_plain
    assert_equal 5800.0, posting3.price
    assert_equal [], posting3.images
    assert_equal ["http://images.craigslist.org/3n23kf3lfZZZZZZZZZ94j1160e7d7b0601934.jpg", "http://images.craigslist.org/3nc3kf3p2ZZZZZZZZZ94j04fbc71e0a551ace.jpg", "http://images.craigslist.org/3nc3k33l7ZZZZZZZZZ94k13d8d7b1024e1e0e.jpg", "http://images.craigslist.org/3n23k63mfZZZZZZZZZ94k7838ae5d48d91eb8.jpg"], posting3.pics
    assert_equal [:pic], posting3.img_types

    # This one ended up being quite a curveball since the user uploaded HTML was such junk:
    posting4 = CraigScrape::Posting.new relative_uri_for('post_samples/posting4.html')
    assert_equal 19412, posting4.contents.length
    assert_equal ["south florida craigslist", "broward county", "real estate - by broker"], posting4.full_section
    assert_equal "$225000 / 3br - Palm Aire Golf Corner Unit!", posting4.header
    assert_equal "Palm Aire Golf Corner Unit!", posting4.title
    assert_equal "$225000 / 3br - Palm Aire Golf Corner Unit!", posting4.label
    assert_equal nil, posting4.location
    assert_equal 1139303170, posting4.posting_id
    assert_equal "hous-sk9f2-1139303170@craigslist.org", posting4.reply_to 
    assert_equal [0, 8, 9, 25, 4, 2009, 6, 115, true, "EDT"], posting4.post_time.to_a
    assert_equal [], posting4.pics
    assert_equal 6396,posting4.contents_as_plain.length
    assert_equal 225000.0, posting4.price
    assert_equal ["http://fortlauderdaleareahomesales.com/myfiles/5.jpg", "http://fortlauderdaleareahomesales.com/myfiles/4.jpg", "http://fortlauderdaleareahomesales.com/myfiles/7.jpg", "http://fortlauderdaleareahomesales.com/myfiles/10.jpg", "http://fortlauderdaleareahomesales.com/myfiles/1.jpg", "http://fortlauderdaleareahomesales.com/myfiles/2.jpg", "http://fortlauderdaleareahomesales.com/myfiles/3.jpg", "http://fortlauderdaleareahomesales.com/myfiles/8.jpg", "http://fortlauderdaleareahomesales.com/myfiles/9.jpg", "http://fortlauderdaleareahomesales.com/myfiles/11.jpg", "http://fortlauderdaleareahomesales.com/myfiles/14.jpg", "http://fortlauderdaleareahomesales.com/myfiles/6.jpg"], posting4.images
    assert_equal [:img], posting4.img_types    
    
    posting5 = CraigScrape::Posting.new relative_uri_for('post_samples/posting5.html')
    assert_equal true, posting5.flagged_for_removal?
    assert_equal nil, posting5.contents
    assert_equal ["south florida craigslist", "palm beach co", "apts/housing for rent"], posting5.full_section
    assert_equal "This posting has been <a href=\"http://www.craigslist.org/about/help/flags_and_community_moderation\">flagged</a> for removal", posting5.header
    assert_equal nil, posting5.title
    assert_equal nil, posting5.label
    assert_equal nil, posting5.location
    assert_equal nil, posting5.posting_id
    assert_equal nil, posting5.reply_to 
    assert_equal nil, posting5.post_time
    assert_equal [],  posting5.pics
    assert_equal nil, posting5.contents_as_plain
    assert_equal nil, posting5.price
    assert_equal [],  posting5.images
    assert_equal [], posting5.img_types
        
    posting_deleted = CraigScrape::Posting.new relative_uri_for('post_samples/this_post_has_been_deleted_by_its_author.html')
    assert_equal true, posting_deleted.deleted_by_author?
    assert_equal nil, posting_deleted.contents
    assert_equal ["south florida craigslist", "broward county", "cars & trucks - by owner"], posting_deleted.full_section
    assert_equal "This posting has been deleted by its author.", posting_deleted.header
    assert_equal nil, posting_deleted.label
    assert_equal nil, posting_deleted.title
    assert_equal nil, posting_deleted.location
    assert_equal nil, posting_deleted.posting_id
    assert_equal nil, posting_deleted.reply_to 
    assert_equal nil, posting_deleted.post_time
    assert_equal [],  posting_deleted.pics
    assert_equal nil, posting_deleted.contents_as_plain
    assert_equal nil, posting_deleted.price
    assert_equal [], posting_deleted.images
    assert_equal [], posting_deleted.img_types

    posting6 = CraigScrape::Posting.new relative_uri_for('post_samples/1207457727.html')
    assert_equal "<p><br>Call!! asking for a new owner.<br>  no deposit required rent to own properties. <br> <br> Defaulting payment records are not a problem, <br> we will help you protect the previous owners credit history! 202-567-6371  <br><br></p>",posting6.contents
    assert_equal "Call!! asking for a new owner.  no deposit required rent to own properties.   Defaulting payment records are not a problem,  we will help you protect the previous owners credit history! 202-567-6371  ",posting6.contents_as_plain
    assert_equal false,posting6.deleted_by_author?
    assert_equal false,posting6.flagged_for_removal?
    assert_equal ["south florida craigslist", "broward county", "apts/housing for rent"],posting6.full_section
    assert_equal "$1350 / 3br - 2bth for no deposit req (Coral Springs)",posting6.header
    assert_equal "$1350 / 3br - 2bth for no deposit req",posting6.label
    assert_equal ["http://images.craigslist.org/3k43pe3o8ZZZZZZZZZ9655022102a3ea51624.jpg", "http://images.craigslist.org/3n13m53p6ZZZZZZZZZ96596515e51237a179c.jpg", "http://images.craigslist.org/3od3p33leZZZZZZZZZ9656d614da8e3a51dd9.jpg", "http://images.craigslist.org/3pb3oa3leZZZZZZZZZ965eb60e4d2344019fb.jpg"],posting6.pics
    assert_equal 'Coral Springs',posting6.location
    assert_equal [0, 56, 18, 5, 6, 2009, 5, 156, true, "EDT"],posting6.post_time.to_a
    assert_equal 1207457727,posting6.posting_id
    assert_equal 1350.0,posting6.price
    assert_equal "hous-ccpap-1207457727@craigslist.org",posting6.reply_to
    assert_equal "2bth for no deposit req",posting6.title    
    assert_equal [], posting6.images
    assert_equal ["http://images.craigslist.org/3k43pe3o8ZZZZZZZZZ9655022102a3ea51624.jpg", "http://images.craigslist.org/3n13m53p6ZZZZZZZZZ96596515e51237a179c.jpg", "http://images.craigslist.org/3od3p33leZZZZZZZZZ9656d614da8e3a51dd9.jpg", "http://images.craigslist.org/3pb3oa3leZZZZZZZZZ965eb60e4d2344019fb.jpg"], posting6.pics
    assert_equal [:pic], posting6.img_types
    
    brw_reb_1224008903 = CraigScrape::Posting.new relative_uri_for('post_samples/brw_reb_1224008903.html')
    assert_equal "Nice 3 Bedroom/ 2 Bathroom/ Garage Home in Sunrise.  1,134 square feet of living area with a 6,000 square foot lot.  Wood laminate flooring throughout the entire house.  House has been updated.  Stamped concrete driveway which leads to garage.  Big back yard.  Central AC.  Washer/Dryer.  Not a short sale or foreclosure. Asking $189,999.  Call Charles Schneider (The Best Damn Real Estate Company Period!) at 954-478-4784.\r<br>\n\r<br>\nDirections: Take Pine Island Road north off of Sunrise Boulevard (past Sunset Strip) to N.W. 25th Court.  Head west (left) on N.W. 25th Court to N.W. 91st Lane.  Head north (right) on N.W. 91st Lane to N.W. 26th Street.  Head east (right) on N.W. 26th Street to the property- 9163 N.W. 26th Street, Sunrise, FL 33322", brw_reb_1224008903.contents
    assert_equal "Nice 3 Bedroom/ 2 Bathroom/ Garage Home in Sunrise.  1,134 square feet of living area with a 6,000 square foot lot.  Wood laminate flooring throughout the entire house.  House has been updated.  Stamped concrete driveway which leads to garage.  Big back yard.  Central AC.  Washer/Dryer.  Not a short sale or foreclosure. Asking $189,999.  Call Charles Schneider (The Best Damn Real Estate Company Period!) at 954-478-4784.\r\n\r\nDirections: Take Pine Island Road north off of Sunrise Boulevard (past Sunset Strip) to N.W. 25th Court.  Head west (left) on N.W. 25th Court to N.W. 91st Lane.  Head north (right) on N.W. 91st Lane to N.W. 26th Street.  Head east (right) on N.W. 26th Street to the property- 9163 N.W. 26th Street, Sunrise, FL 33322", brw_reb_1224008903.contents_as_plain
    assert_equal false, brw_reb_1224008903.deleted_by_author?
    assert_equal false, brw_reb_1224008903.flagged_for_removal?
    assert_equal ["south florida craigslist", "broward county", "real estate - by broker"], brw_reb_1224008903.full_section
    assert_equal "$189999 / 3br - Nice 3 Bedroom/ 2 Bathroom House with Garage in Sunrise (Sunrise) (map)", brw_reb_1224008903.header
    assert_equal "$189999 / 3br - Nice 3 Bedroom/ 2 Bathroom House with Garage in Sunrise (Sunrise) (map)", brw_reb_1224008903.header_as_plain
    assert_equal ["http://images.craigslist.org/3ma3o93laZZZZZZZZZ96g5ee7cc528f1818a8.jpg", "http://images.craigslist.org/3nf3m03oeZZZZZZZZZ96gb267b7db57d91f60.jpg", "http://images.craigslist.org/3m63oc3p1ZZZZZZZZZ96g521443416aea1cac.jpg", "http://images.craigslist.org/3nc3p53l5ZZZZZZZZZ96g8706fce2c0bb17e9.jpg"], brw_reb_1224008903.pics
    assert_equal "Sunrise", brw_reb_1224008903.location
    assert_equal [0, 43, 18, 16, 6, 2009, 2, 167, true, "EDT"], brw_reb_1224008903.post_time.to_a
    assert_equal 1224008903, brw_reb_1224008903.posting_id
    assert_equal 189999.0, brw_reb_1224008903.price
    assert_equal "1971CJS@Bellsouth.net", brw_reb_1224008903.reply_to
    assert_equal false, brw_reb_1224008903.system_post?
    assert_equal "Nice 3 Bedroom/ 2 Bathroom House with Garage in Sunrise", brw_reb_1224008903.title
    assert_equal "$189999 / 3br - Nice 3 Bedroom/ 2 Bathroom House with Garage in Sunrise", brw_reb_1224008903.label
    assert_equal [], brw_reb_1224008903.images
    assert_equal ["http://images.craigslist.org/3ma3o93laZZZZZZZZZ96g5ee7cc528f1818a8.jpg", "http://images.craigslist.org/3nf3m03oeZZZZZZZZZ96gb267b7db57d91f60.jpg", "http://images.craigslist.org/3m63oc3p1ZZZZZZZZZ96g521443416aea1cac.jpg", "http://images.craigslist.org/3nc3p53l5ZZZZZZZZZ96g8706fce2c0bb17e9.jpg"], brw_reb_1224008903.pics
    assert_equal [:pic], brw_reb_1224008903.img_types
    
    sfbay_art_1223614914 = CraigScrape::Posting.new relative_uri_for('post_samples/sfbay_art_1223614914.html')
    assert_equal "Bombay Company Beautiful Art Postered Painting \r<br>\n\225\tThe most beautiful piece of art you could have\r<br>\n\225\tMatches with any type of furnishing and decoration\r<br>\n\225\tA must see/Only one year old\r<br>\n\225\tRegular Price @ $1500.00\r<br>\n\225\tSale Price @ $650.00\r<br>", sfbay_art_1223614914.contents
    assert_equal "Bombay Company Beautiful Art Postered Painting \r\n\225\tThe most beautiful piece of art you could have\r\n\225\tMatches with any type of furnishing and decoration\r\n\225\tA must see/Only one year old\r\n\225\tRegular Price @ $1500.00\r\n\225\tSale Price @ $650.00\r", sfbay_art_1223614914.contents_as_plain
    assert_equal false, sfbay_art_1223614914.deleted_by_author?
    assert_equal false, sfbay_art_1223614914.flagged_for_removal?
    assert_equal ["SF bay area craigslist", "south bay", "art & crafts"], sfbay_art_1223614914.full_section
    assert_equal "Bombay Company Art Painting - $650 (saratoga)", sfbay_art_1223614914.header
    assert_equal "Bombay Company Art Painting - $650 (saratoga)", sfbay_art_1223614914.header_as_plain
    assert_equal ["http://images.craigslist.org/3kf3o93laZZZZZZZZZ96fbc594a6ceb1f1025.jpg"], sfbay_art_1223614914.pics
    assert_equal "Bombay Company Art Painting - $650", sfbay_art_1223614914.label
    assert_equal 'saratoga', sfbay_art_1223614914.location
    assert_equal [0, 0, 0, 15, 6, 2009, 1, 166, true, "EDT"], sfbay_art_1223614914.post_date.to_a
    assert_equal [0, 38, 22, 15, 6, 2009, 1, 166, true, "EDT"], sfbay_art_1223614914.post_time.to_a
    assert_equal 1223614914, sfbay_art_1223614914.posting_id
    assert_equal 650.0, sfbay_art_1223614914.price
    assert_equal "sale-trzm8-1223614914@craigslist.org", sfbay_art_1223614914.reply_to
    assert_equal false, sfbay_art_1223614914.system_post?
    assert_equal "Bombay Company Art Painting", sfbay_art_1223614914.title
    assert_equal [], sfbay_art_1223614914.images
    assert_equal ["http://images.craigslist.org/3kf3o93laZZZZZZZZZ96fbc594a6ceb1f1025.jpg"], sfbay_art_1223614914.pics
    assert_equal [:pic], sfbay_art_1223614914.img_types
  end
  
  # This is actually a 'bug' with hpricot itself when the ulimit is set too low. 
  # the Easy fix is running "ulimit -s 16384" before the tests. But the better fix was
  # to remove the userbody sending these pages to be parsed by Hpricot
  def test_bugs_found061710
    posting_061710 = CraigScrape::Posting.new relative_uri_for('post_samples/posting1796890756-061710.html')
    
    assert_equal false, posting_061710.deleted_by_author?
    assert_equal true, posting_061710.downloaded?
    assert_equal false, posting_061710.flagged_for_removal?
    assert_equal ["south florida craigslist", "miami / dade", "for sale / wanted", "general for sale"], posting_061710.full_section
    assert_equal false, posting_061710.has_img?
    assert_equal false, posting_061710.has_pic?
    assert_equal false, posting_061710.has_pic_or_img?
    assert_equal "*****SOFTWARE**** (Dade/Broward)", posting_061710.header
    assert_equal "*****SOFTWARE**** (Dade/Broward)", posting_061710.header_as_plain
    assert_equal nil, posting_061710.href
    assert_equal [], posting_061710.images
    assert_equal [], posting_061710.img_types
    assert_equal "*****SOFTWARE****", posting_061710.label
    assert_equal "Dade/Broward", posting_061710.location
    assert_equal [], posting_061710.pics
    assert_equal [0, 0, 0, 17, 6, 2010, 4, 168, true, "EDT"], posting_061710.post_date.to_a
    assert_equal [0, 22, 13, 17, 6, 2010, 4, 168, true, "EDT"], posting_061710.post_time.to_a
    assert_equal 1796890756, posting_061710.posting_id
    assert_equal nil, posting_061710.price
    assert_equal nil, posting_061710.reply_to
    assert_equal "general for sale", posting_061710.section
    assert_equal false, posting_061710.system_post?
    assert_equal "*****SOFTWARE****", posting_061710.title
    
    posting1808219423 = CraigScrape::Posting.new relative_uri_for('post_samples/posting1808219423.html')
    assert_equal false, posting1808219423.deleted_by_author?
    assert_equal true, posting1808219423.downloaded?
    assert_equal false, posting1808219423.flagged_for_removal?
    assert_equal ["south florida craigslist", "miami / dade", "for sale / wanted", "general for sale"], posting1808219423.full_section
    assert_equal true, posting1808219423.has_img?
    assert_equal false, posting1808219423.has_pic?
    assert_equal true, posting1808219423.has_pic_or_img?
    assert_equal "*Software*AdobeCS5*RosettaStone*AutoCAD*Windows7*Office2010*&* More (Dade/Broward)", posting1808219423.header
    assert_equal "*Software*AdobeCS5*RosettaStone*AutoCAD*Windows7*Office2010*&* More (Dade/Broward)", posting1808219423.header_as_plain
    assert_equal nil, posting1808219423.href
    assert_equal ["http://i800.photobucket.com/albums/yy287/todofull69/Programas/office-2010.jpg", "http://i844.photobucket.com/albums/ab10/fziqe/adobeblogcopy.jpg", "http://i31.photobucket.com/albums/c383/drapizan/RosettaStone.jpg", "http://i1002.photobucket.com/albums/af142/tagurtoast/Windows_7.jpg", "http://i800.photobucket.com/albums/yy287/todofull69/Programas/office-2010.jpg", "http://i844.photobucket.com/albums/ab10/fziqe/adobeblogcopy.jpg", "http://i31.photobucket.com/albums/c383/drapizan/RosettaStone.jpg", "http://i1002.photobucket.com/albums/af142/tagurtoast/Windows_7.jpg", "http://i800.photobucket.com/albums/yy287/todofull69/Programas/office-2010.jpg", "http://i844.photobucket.com/albums/ab10/fziqe/adobeblogcopy.jpg", "http://i31.photobucket.com/albums/c383/drapizan/RosettaStone.jpg", "http://i1002.photobucket.com/albums/af142/tagurtoast/Windows_7.jpg", "http://i800.photobucket.com/albums/yy287/todofull69/Programas/office-2010.jpg", "http://i844.photobucket.com/albums/ab10/fziqe/adobeblogcopy.jpg", "http://i31.photobucket.com/albums/c383/drapizan/RosettaStone.jpg", "http://i1002.photobucket.com/albums/af142/tagurtoast/Windows_7.jpg", "http://i800.photobucket.com/albums/yy287/todofull69/Programas/office-2010.jpg", "http://i844.photobucket.com/albums/ab10/fziqe/adobeblogcopy.jpg", "http://i31.photobucket.com/albums/c383/drapizan/RosettaStone.jpg", "http://i1002.photobucket.com/albums/af142/tagurtoast/Windows_7.jpg"], posting1808219423.images
    assert_equal [:img], posting1808219423.img_types
    assert_equal "*Software*AdobeCS5*RosettaStone*AutoCAD*Windows7*Office2010*&* More", posting1808219423.label
    assert_equal "Dade/Broward", posting1808219423.location
    assert_equal [], posting1808219423.pics
    assert_equal [0, 0, 0, 24, 6, 2010, 4, 175, true, "EDT"], posting1808219423.post_date.to_a
    assert_equal [0, 35, 7, 24, 6, 2010, 4, 175, true, "EDT"], posting1808219423.post_time.to_a
    assert_equal 1808219423, posting1808219423.posting_id
    assert_equal nil, posting1808219423.price
    assert_equal nil, posting1808219423.reply_to
    assert_equal "general for sale", posting1808219423.section
    assert_equal false, posting1808219423.system_post?
    assert_equal "*Software*AdobeCS5*RosettaStone*AutoCAD*Windows7*Office2010*&* More", posting1808219423.title
  end
  
  def test_bug_found090610
    posting_090610 = CraigScrape::Posting.new relative_uri_for('post_samples/posting1938291834-090610.html')

    assert_equal 27629, posting_090610.contents.length 
    assert_equal 2326, posting_090610.contents_as_plain.length
    assert_equal false, posting_090610.deleted_by_author?
    assert_equal true, posting_090610.downloaded?
    assert_equal false, posting_090610.flagged_for_removal?
    assert_equal ["boston craigslist", "boston/camb/brook", "for sale / wanted", "arts & crafts"], posting_090610.full_section
    assert_equal true, posting_090610.has_img?
    assert_equal false, posting_090610.has_pic?
    assert_equal true, posting_090610.has_pic_or_img?
    assert_equal "2008 GMC Sierra 2500HD - $14800 (boston)", posting_090610.header
    assert_equal "2008 GMC Sierra 2500HD - $14800 (boston)", posting_090610.header_as_plain
    assert_equal nil, posting_090610.href
    assert_equal ["http://i866.photobucket.com/albums/ab228/rodreigo/GMC%20Sierra/used-2008-gmc-sierra_2500hd-slttruckcrewcabstandardbed-5703-5793520-2-400-1.jpg", "http://i866.photobucket.com/albums/ab228/rodreigo/GMC%20Sierra/used-2008-gmc-sierra_2500hd-slttruckcrewcabstandardbed-5703-5793520-1-400.jpg", "http://i866.photobucket.com/albums/ab228/rodreigo/GMC%20Sierra/used-2008-gmc-sierra_2500hd-slttruckcrewcabstandardbed-5703-5793520-29-640.jpg", "http://i866.photobucket.com/albums/ab228/rodreigo/GMC%20Sierra/used-2008-gmc-sierra_2500hd-slttruckcrewcabstandardbed-5703-5793520-11-640.jpg"], posting_090610.images
    assert_equal [:img], posting_090610.img_types
    assert_equal "2008 GMC Sierra 2500HD - $14800", posting_090610.label
    assert_equal "boston", posting_090610.location
    assert_equal [], posting_090610.pics
    assert_equal [0, 0, 0, 5, 9, 2010, 0, 248, true, "EDT"], posting_090610.post_date.to_a
    assert_equal [0, 29, 18, 5, 9, 2010, 0, 248, true, "EDT"], posting_090610.post_time.to_a
    assert_equal 1938291834, posting_090610.posting_id
    assert_equal 14800.0, posting_090610.price
    assert_equal nil, posting_090610.reply_to
    assert_equal "arts & crafts", posting_090610.section
    assert_equal false, posting_090610.system_post?
    assert_equal "2008 GMC Sierra 2500HD", posting_090610.title
  end

end