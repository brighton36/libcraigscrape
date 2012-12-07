# encoding: UTF-8
require 'spec_helper'

describe CraigScrape::Posting do
  context "this_post_has_expired_old.html" do
    subject{ described_class.new uri_for('this_post_has_expired_old.html') }
 
    its(:posting_has_expired?){ should be_true }
  end

  context "posting_page_not_found_120512.html" do
    subject{ described_class.new uri_for('posting_page_not_found_120512.html') }

    its(:system_post?){ should be_true }
  end

  context "posting_mdc_cto_ftl_112612.html" do
    subject{ described_class.new uri_for('posting_mdc_cto_ftl_112612.html') }

    its(:title)    {should eq("1999 Mustang GT w/ '08 3 Valve Engine Swap")}
    its(:contents) {should eq("I am selling my 1999 Mustang GT with a 2008 GT 3 Valve engine swap. The car is a 5 speed with 3.73 rear gears. It has a Diablo Sport chip with 2 tunes. The rear tires have plentyt of tread and are Michelin Pilot sports ($700 less than a year ago). The rims are staggered and are less than a year old. The car has a 2003 Mustang Cobra hood. It also has a 2003 Cobra front bumper. The paint on the car is less than a year old. The bad: The car will need 2 front tires soon. They are currently Nitto 555's. The A/C Compressor will need changing soon as it is making a little noise. It works but I dont use it just in case. The drivers side seat needs to be re-upholstered also. Minor problems considering the work that went into this car. The instrument cluster is from a Mach 1 and shows 120,000 miles, but the engine has around 70,000 miles. <br><br>\nA lot of time and money was spent on this car to do the swap right. It is my daily driver and has never given me a single problem. It's always had Mobil 1 Synthetic oil and it's plenty fast and a lot of fun to drive. If you are looking for something unique and you are a Mustang fan, you might want to consider this car.<br><br>\nThe seats are from a newer model Mustang GT. The car runs really good, and turns heads everywhere it goes, especially when I pop the hood and those in the know see the engine that doesnt belong there.  : )<br><br>\nI am will consider all offers so please don't be shy, the worse that I can do is say no. I am interested in some specific cars as well that I willl consider on trade. BMW 530 or 540, Infinity G35, Lexus IS 300 or GS300 or 400. I respond better to texts or emails. Call with any quesrtions. 305-310-5993 or email me at Torresa76@aol.com<br><br>\nThanks for looking.  : )")}
    its(:contents_as_plain) {should eq("I am selling my 1999 Mustang GT with a 2008 GT 3 Valve engine swap. The car is a 5 speed with 3.73 rear gears. It has a Diablo Sport chip with 2 tunes. The rear tires have plentyt of tread and are Michelin Pilot sports ($700 less than a year ago). The rims are staggered and are less than a year old. The car has a 2003 Mustang Cobra hood. It also has a 2003 Cobra front bumper. The paint on the car is less than a year old. The bad: The car will need 2 front tires soon. They are currently Nitto 555's. The A/C Compressor will need changing soon as it is making a little noise. It works but I dont use it just in case. The drivers side seat needs to be re-upholstered also. Minor problems considering the work that went into this car. The instrument cluster is from a Mach 1 and shows 120,000 miles, but the engine has around 70,000 miles. \nA lot of time and money was spent on this car to do the swap right. It is my daily driver and has never given me a single problem. It's always had Mobil 1 Synthetic oil and it's plenty fast and a lot of fun to drive. If you are looking for something unique and you are a Mustang fan, you might want to consider this car.\nThe seats are from a newer model Mustang GT. The car runs really good, and turns heads everywhere it goes, especially when I pop the hood and those in the know see the engine that doesnt belong there.  : )\nI am will consider all offers so please don't be shy, the worse that I can do is say no. I am interested in some specific cars as well that I willl consider on trade. BMW 530 or 540, Infinity G35, Lexus IS 300 or GS300 or 400. I respond better to texts or emails. Call with any quesrtions. 305-310-5993 or email me at Torresa76@aol.com\nThanks for looking.  : )")}
  end

  context "posting_daytona_art_120512.html" do
    subject{ described_class.new uri_for('posting_daytona_art_120512.html') }

    its(:title)             {should eq("METAL SCULPTURES GREAT Christmas gifts")}
    its(:contents_as_plain) {should eq("Assorted Metal sculptures from local artist,  call 386 235-4390")}
  end

  context "posting_daytona_art_120512-2.html" do
  
    subject{ described_class.new uri_for('posting_daytona_art_120512-2.html') }

    its(:title)    {should eq("Premier Bouquet Wrap")}
    its(:contents) {should eq("THESE ARE USED IN FLOWER / CRAFT SHOPS . ALL ARE NEW, BOXED AND AND VERY WELL MADE. I HAVE A CASE OF THESE I WILL SELL FOR ONE PRICE, OR WILL SELL BY THE PIECE. CASE PRICE IS FOR ABOUT 144 PIECES $75.00. <br><br>\nPremier Bouquet Wrap<br><br>\nFlower Bridal  Bouquet Wrap White/Satin <br><br>\nNew White Satin <br><br>\nThe wraps are approximately 6 1/2\" Long <br><br>\nThe bridal bouquet wrap is a creative alternative to tying a ribbon around your flowers. Just slide the wrap around flower stems<br><br>\nThis wrap is perfect for covering/decorating the stems on \"Wedding\", Quinceañera\" or \"Prom\" bouquets. They can also be used with \"Wedding bouquet\" holder handles.  These wraps are made with quality Satin material, easy to install and feels soft and smooth on the Bride's or Bridesmaid's hands.  These wraps put the finishing touches on any Floral Wedding Bouquet.<br><br>\nPLEASE CALL . . .<br><br>\nAJ-518-858-2002<br><br><br>")}
  end
  
  context "posting_mdc_reb_120612.html" do
    subject{ described_class.new uri_for('posting_mdc_reb_120612.html') }
    its(:system_post?){ should be_false }
    its(:title)    {should eq("✱✱✱BEAUTIFUL HOUSE FOR SALE IN FLORIDA KEYS  ") }
    its(:contents) {should eq("\u0095 $1,149,000.00                  <br>\n\u0095 2000ft²<br>\n\u0095 3-bedroom<br>\n\u0095 3-full bath<br><br>\nJUST REDUCED FOR A QUICK SALE!!!!<br><br>\nThis great Three Story 3-bedroom 3 Full bath home in Islamorada, Florida Keys is the perfect get-away to relax, enjoy the fresh breezes, the sandy beach and watch spectacular sunsets. A spacious master suite bedroom upstairs has a private bath with whirlpool Jacuzzi tub and private patio. Downstairs you have access to full kitchen custom cabinets, granite countertops, stainless steel appliances, open living-dining room, Travertine marble throughout the whole house, two bedrooms and two full baths. Enjoy a concrete dock and davits with boat access to the Gulf and ocean in less than five minutes via the deep-water canal right outside your door. Enjoy access to a private community beach with picnic tables and tiki huts for fun barbecues; jet skiing; boat ramp and recreational boating and water skiing. Don't miss out on these .Located in a quiet neighborhood at Mile Marker 74 in Islamorada, this location is tastefully furnished, has a gourmet kitchen and is ideal for boaters.<br><br>\n(hablamos español)    <br><br>\nCall for appointment 305.467.6348 /  786.484.0917<br>\nMarisol Acosta<br>\nLicensed, Realtor Associate<br>\nAkoya Realty LLC<br>\nwww.akoyarealty.com") }
  end
end
