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

  context "posting_sya_121012.html" do
    # This example was picked since it has pics
    subject{ described_class.new uri_for('posting_sya_121012.html') }

    its(:full_section) {should eq(["south florida craigslist", "miami / dade", "for sale / wanted", "computers - by dealer"])}
    its(:header)       {should eq("Sony Vaio - $480 (orlando,florida)")}
    its(:label)        {should eq("Sony Vaio - $480")}
    its(:title)        {should eq("Sony Vaio")}
    its(:location)     {should eq('orlando,florida')}
    its(:posting_id)   {should eq(3469913065)}
    its(:reply_to)     {should eq('9cxgv-3469913065@sale.craigslist.org')}
    its(:post_time)    {should eq(Time.parse('2012-12-10 20:51:00 -0500'))}
    its(:price)        {should eq(480)}
    its(:images)       {should eq([])}
    its(:pics) do
      pics_list = ['3Eb3Fc3M25Ne5Ed5J6cca593d0c806b3614c1',
        '3K73L43J45G25H55J1cca2d0db7d75fe11448', '3E53Gc3F85I95K25M1ccaf6c5790cbd541b57',
        '3G83Kc3F15L45E75J9cca7e4e7fbdfe981fd9', '3Kc3ma3N65Le5Kf5U3ccae67bd8aa8129140c'
      ].collect{|src| ['http://images.craigslist.org/', src, '.jpg'].join }
      should eq( pics_list )
    end
    its(:img_types)    {should eq([:pic])}
    its(:contents_as_plain) {should eq("Sony Vaio for sale! Its in great condition but I no longer hard need for it. No low ball offers!!")}
    its(:contents) {should eq("<br>Sony Vaio for sale! Its in great condition but I no longer hard need for it. No low ball offers!!<br><br><br><br>")}
  end

  context "posting_sya_121012-2.html" do
    # This example was picked since it has images and no text
    subject{ described_class.new uri_for('posting_sya_121012-2.html') }

    its(:full_section) {should eq(["south florida craigslist", "broward county", "for sale / wanted", "computers - by dealer"])}
    its(:header)       {should eq("METRO PCS ★ANDROID★SMARTPHONE★ Samsung SCH Admire Red Clean ES - $80 (BROWARD)")}
    its(:label)        {should eq("METRO PCS ★ANDROID★SMARTPHONE★ Samsung SCH Admire Red Clean ES - $80")}
    its(:title)        {should eq("METRO PCS ★ANDROID★SMARTPHONE★ Samsung SCH Admire Red Clean ES")}
    its(:location)     {should eq('BROWARD')}
    its(:posting_id)   {should eq(3469905497)}
    its(:reply_to)     {should eq('z7jmh-3469905497@sale.craigslist.org')}
    its(:post_time)    {should eq(Time.parse('2012-12-10 20:47:00 -0500'))}
    its(:price)        {should eq(80)}
    its(:images) do 
      images_list = ["http://i1157.photobucket.com/albums/p590/emy123000/T2eC16NE9s2fp7dBQuCykypg60_12.jpg", "http://i1157.photobucket.com/albums/p590/emy123000/KGrHqZqwFCS4TIRoZBQKvdVJIQ60_57.jpg", "http://i1157.photobucket.com/albums/p590/emy123000/KGrHqZqwFCS4TIRoZBQKvdVJIQ60_57.jpg", "http://i1157.photobucket.com/albums/p590/emy123000/ScreenShot2012-06-25at60811AM.png", "http://i1157.photobucket.com/albums/p590/emy123000/KGrHqZowFCp4FZqoWBQvsVUbFdw60_12.jpg"]

      should eq(images_list)
    end
    its(:pics)         {should eq([])}
    its(:img_types)    {should eq([:img])}
    its(:contents_as_plain) {should eq("")}
    its(:contents) {should eq("<a href=\"http://s1157.photobucket.com/albums/p590/emy123000/?action=view&current=T2eC16NE9s2fp7dBQuCykypg60_12.jpg\" target=\"_blank\" rel=\"nofollow\"><img src=\"http://i1157.photobucket.com/albums/p590/emy123000/T2eC16NE9s2fp7dBQuCykypg60_12.jpg\" border=\"0\" alt=\"Photobucket\"></a><br><a href=\"http://s1157.photobucket.com/albums/p590/emy123000/?action=view&current=KGrHqZqwFCS4TIRoZBQKvdVJIQ60_57.jpg\" target=\"_blank\" rel=\"nofollow\"><img src=\"http://i1157.photobucket.com/albums/p590/emy123000/KGrHqZqwFCS4TIRoZBQKvdVJIQ60_57.jpg\" border=\"0\" alt=\"Photobucket\"></a><a href=\"http://s1157.photobucket.com/albums/p590/emy123000/?action=view&current=KGrHqZqwFCS4TIRoZBQKvdVJIQ60_57.jpg\" target=\"_blank\" rel=\"nofollow\"><img src=\"http://i1157.photobucket.com/albums/p590/emy123000/KGrHqZqwFCS4TIRoZBQKvdVJIQ60_57.jpg\" border=\"0\" alt=\"Photobucket\"></a><a href=\"http://s1157.photobucket.com/albums/p590/emy123000/?action=view&current=ScreenShot2012-06-25at60811AM.png\" target=\"_blank\" rel=\"nofollow\"><img src=\"http://i1157.photobucket.com/albums/p590/emy123000/ScreenShot2012-06-25at60811AM.png\" border=\"0\" alt=\"Photobucket\"></a><a href=\"http://s1157.photobucket.com/albums/p590/emy123000/?action=view&current=KGrHqZowFCp4FZqoWBQvsVUbFdw60_12.jpg\" target=\"_blank\" rel=\"nofollow\"><img src=\"http://i1157.photobucket.com/albums/p590/emy123000/KGrHqZowFCp4FZqoWBQvsVUbFdw60_12.jpg\" border=\"0\" alt=\"Photobucket\"></a>")}
  end

  context "posting_mdc_cto_ftl_112612.html" do
    subject{ described_class.new uri_for('posting_mdc_cto_ftl_112612.html') }

    its(:title)    {should eq("1999 Mustang GT w/ '08 3 Valve Engine Swap")}
    its(:contents) {should eq("I am selling my 1999 Mustang GT with a 2008 GT 3 Valve engine swap. The car is a 5 speed with 3.73 rear gears. It has a Diablo Sport chip with 2 tunes. The rear tires have plentyt of tread and are Michelin Pilot sports ($700 less than a year ago). The rims are staggered and are less than a year old. The car has a 2003 Mustang Cobra hood. It also has a 2003 Cobra front bumper. The paint on the car is less than a year old. The bad: The car will need 2 front tires soon. They are currently Nitto 555's. The A/C Compressor will need changing soon as it is making a little noise. It works but I dont use it just in case. The drivers side seat needs to be re-upholstered also. Minor problems considering the work that went into this car. The instrument cluster is from a Mach 1 and shows 120,000 miles, but the engine has around 70,000 miles. <br><br>\nA lot of time and money was spent on this car to do the swap right. It is my daily driver and has never given me a single problem. It's always had Mobil 1 Synthetic oil and it's plenty fast and a lot of fun to drive. If you are looking for something unique and you are a Mustang fan, you might want to consider this car.<br><br>\nThe seats are from a newer model Mustang GT. The car runs really good, and turns heads everywhere it goes, especially when I pop the hood and those in the know see the engine that doesnt belong there.  : )<br><br>\nI am will consider all offers so please don't be shy, the worse that I can do is say no. I am interested in some specific cars as well that I willl consider on trade. BMW 530 or 540, Infinity G35, Lexus IS 300 or GS300 or 400. I respond better to texts or emails. Call with any quesrtions. 305-310-5993 or email me at Torresa76@aol.com<br><br>\nThanks for looking.  : )")}
    its(:contents_as_plain) {should eq("I am selling my 1999 Mustang GT with a 2008 GT 3 Valve engine swap. The car is a 5 speed with 3.73 rear gears. It has a Diablo Sport chip with 2 tunes. The rear tires have plentyt of tread and are Michelin Pilot sports ($700 less than a year ago). The rims are staggered and are less than a year old. The car has a 2003 Mustang Cobra hood. It also has a 2003 Cobra front bumper. The paint on the car is less than a year old. The bad: The car will need 2 front tires soon. They are currently Nitto 555's. The A/C Compressor will need changing soon as it is making a little noise. It works but I dont use it just in case. The drivers side seat needs to be re-upholstered also. Minor problems considering the work that went into this car. The instrument cluster is from a Mach 1 and shows 120,000 miles, but the engine has around 70,000 miles. \nA lot of time and money was spent on this car to do the swap right. It is my daily driver and has never given me a single problem. It's always had Mobil 1 Synthetic oil and it's plenty fast and a lot of fun to drive. If you are looking for something unique and you are a Mustang fan, you might want to consider this car.\nThe seats are from a newer model Mustang GT. The car runs really good, and turns heads everywhere it goes, especially when I pop the hood and those in the know see the engine that doesnt belong there.  : )\nI am will consider all offers so please don't be shy, the worse that I can do is say no. I am interested in some specific cars as well that I willl consider on trade. BMW 530 or 540, Infinity G35, Lexus IS 300 or GS300 or 400. I respond better to texts or emails. Call with any quesrtions. 305-310-5993 or email me at Torresa76@aol.com\nThanks for looking.  : )")}
    its(:full_section) {should eq(["south florida craigslist", "miami / dade", "for sale / wanted", "cars & trucks - by owner"])}
    its(:header)       {should eq("1999 Mustang GT w/ '08 3 Valve Engine Swap - $8500 (Homestead)")}
    its(:label)        {should eq("1999 Mustang GT w/ '08 3 Valve Engine Swap - $8500")}
    its(:location)     {should eq('Homestead')}
    its(:posting_id)   {should eq(3437079882)}
    its(:reply_to)     {should eq(nil)}
    its(:post_time)    {should eq(Time.parse('2012-11-26 21:34:00 -0500'))}
    its(:price)        {should eq(8500)}
    its(:images)       {should eq([])}
    its(:pics) do
      pics_list = ['3M53of3H65N15E15M2cbqdd2e7af939c215a3',
        '3G13F23Hd5I15Nb5T1cbqfb3e2605ddf31b8b', '3n13F23N25Lf5Y65Facbq05143722c4801267',
        '3Ee3Ne3H85N85K15Hecbq79f17c0a2e03136e', '3me3pb3Nb5Le5Hd5Mdcbqe446ce3ce2ef1f80'
      ].collect{|src| ['http://images.craigslist.org/', src, '.jpg'].join }
      should eq( pics_list )
    end
    its(:img_types)    {should eq([:pic])}
  end

  context "posting_daytona_art_120512.html" do
    subject{ described_class.new uri_for('posting_daytona_art_120512.html') }

    its(:full_section) {should eq(["daytona beach craigslist", "for sale / wanted", "arts & crafts - by owner"])}
    its(:header)       {should eq("METAL SCULPTURES GREAT Christmas gifts (ormond)")}
    its(:label)        {should eq("METAL SCULPTURES GREAT Christmas gifts")}
    its(:title)        {should eq("METAL SCULPTURES GREAT Christmas gifts")}
    its(:location)     {should eq('ormond')}
    its(:posting_id)   {should eq(3431080802)}
    its(:reply_to)     {should eq('rbwts-3431080802@sale.craigslist.org')}
    its(:post_time)    {should eq(Time.parse('2012-12-05 21:25:00 -0500'))}
    its(:price)        {should eq(nil)}
    its(:images)       {should eq([])}
    its(:pics)         {should eq(["http://images.craigslist.org/3Kb3M83I85Gc5Ea5H2cbo8eb0fb5e4af71968.jpg", "http://images.craigslist.org/3Lb3M33l35E85F35P0cbod80bd9115e311350.jpg", "http://images.craigslist.org/3Ef3Ib3H55L35K55J6cbof57b4d73878111d0.jpg"])}
    its(:img_types)    {should eq([:pic])}
    its(:contents_as_plain) {should eq("Assorted Metal sculptures from local artist,  call 386 235-4390")}
    its(:contents) {should eq("Assorted Metal sculptures from local artist,  call 386 235-4390")}
  end

  context "posting_daytona_art_120512-2.html" do
    subject{ described_class.new uri_for('posting_daytona_art_120512-2.html') }

    its(:full_section) {should eq(["daytona beach craigslist", "for sale / wanted", "arts & crafts - by owner"])}
    its(:header)       {should eq("Premier Bouquet Wrap - $2 (PALM COAST)")}
    its(:label)        {should eq("Premier Bouquet Wrap - $2")}
    its(:title)        {should eq("Premier Bouquet Wrap")}
    its(:location)     {should eq('PALM COAST')}
    its(:posting_id)   {should eq(3448282416)}
    its(:reply_to)     {should eq('nqmhm-3448282416@sale.craigslist.org')}
    its(:post_time)    {should eq(Time.parse('2012-12-01 15:02:00 -0500'))}
    its(:price)        {should eq(2)}
    its(:images)       {should eq([])}
    its(:pics)         {should eq(["http://images.craigslist.org/3I93pe3Hf5G75J55M2cc13e19b59314771029.jpg"])}
    its(:img_types)    {should eq([:pic])}
    its(:contents_as_plain) {should eq("THESE ARE USED IN FLOWER / CRAFT SHOPS . ALL ARE NEW, BOXED AND AND VERY WELL MADE. I HAVE A CASE OF THESE I WILL SELL FOR ONE PRICE, OR WILL SELL BY THE PIECE. CASE PRICE IS FOR ABOUT 144 PIECES $75.00. \nPremier Bouquet Wrap\nFlower Bridal  Bouquet Wrap White/Satin \nNew White Satin \nThe wraps are approximately 6 1/2\" Long \nThe bridal bouquet wrap is a creative alternative to tying a ribbon around your flowers. Just slide the wrap around flower stems\nThis wrap is perfect for covering/decorating the stems on \"Wedding\", Quinceañera\" or \"Prom\" bouquets. They can also be used with \"Wedding bouquet\" holder handles.  These wraps are made with quality Satin material, easy to install and feels soft and smooth on the Bride's or Bridesmaid's hands.  These wraps put the finishing touches on any Floral Wedding Bouquet.\nPLEASE CALL . . .\nAJ-518-858-2002")}
    its(:contents) {should eq("THESE ARE USED IN FLOWER / CRAFT SHOPS . ALL ARE NEW, BOXED AND AND VERY WELL MADE. I HAVE A CASE OF THESE I WILL SELL FOR ONE PRICE, OR WILL SELL BY THE PIECE. CASE PRICE IS FOR ABOUT 144 PIECES $75.00. <br><br>\nPremier Bouquet Wrap<br><br>\nFlower Bridal  Bouquet Wrap White/Satin <br><br>\nNew White Satin <br><br>\nThe wraps are approximately 6 1/2\" Long <br><br>\nThe bridal bouquet wrap is a creative alternative to tying a ribbon around your flowers. Just slide the wrap around flower stems<br><br>\nThis wrap is perfect for covering/decorating the stems on \"Wedding\", Quinceañera\" or \"Prom\" bouquets. They can also be used with \"Wedding bouquet\" holder handles.  These wraps are made with quality Satin material, easy to install and feels soft and smooth on the Bride's or Bridesmaid's hands.  These wraps put the finishing touches on any Floral Wedding Bouquet.<br><br>\nPLEASE CALL . . .<br><br>\nAJ-518-858-2002<br><br><br>")}
  end
  
  context "posting_mdc_reb_120612.html" do
    subject{ described_class.new uri_for('posting_mdc_reb_120612.html') }
    its(:system_post?){ should be_false }

    its(:full_section) {should eq(["south florida craigslist", "miami / dade", "housing", "real estate - by broker"])}
    its(:header)       {should eq("$1149000 / 3br - 2000ft² - ✱✱✱BEAUTIFUL HOUSE FOR SALE IN FLORIDA KEYS   (Florida Key Islamorada)")}
    its(:label)        {should eq("$1149000 / 3br - 2000ft² - ✱✱✱BEAUTIFUL HOUSE FOR SALE IN FLORIDA KEYS")}
    its(:title)        {should eq("✱✱✱BEAUTIFUL HOUSE FOR SALE IN FLORIDA KEYS  ")}
    its(:location)     {should eq('Florida Key Islamorada')}
    its(:posting_id)   {should eq(3438004368)}
    its(:reply_to)     {should eq('p7h8m-3438004368@hous.craigslist.org')}
    its(:post_time)    {should eq(Time.parse('2012-12-05 12:46:00 -0500'))}
    its(:price)        {should eq(1149000)}
    its(:images)       {should eq([])}
    its(:pics)         {should eq(["http://images.craigslist.org/3M43Jb3ld5L55Z35M5cbr12a6ec99f72d18e2.jpg", "http://images.craigslist.org/3L73H63l45I55L35G4cbr8902484988f3112f.jpg", "http://images.craigslist.org/3Le3Ic3Hf5I75La5M1cbrdd1617f48d4c1f02.jpg"])}
    its(:img_types)    {should eq([:pic])}
    its(:contents_as_plain)    {should eq("\u0095 $1,149,000.00                  \n\u0095 2000ft²\n\u0095 3-bedroom\n\u0095 3-full bath\nJUST REDUCED FOR A QUICK SALE!!!!\nThis great Three Story 3-bedroom 3 Full bath home in Islamorada, Florida Keys is the perfect get-away to relax, enjoy the fresh breezes, the sandy beach and watch spectacular sunsets. A spacious master suite bedroom upstairs has a private bath with whirlpool Jacuzzi tub and private patio. Downstairs you have access to full kitchen custom cabinets, granite countertops, stainless steel appliances, open living-dining room, Travertine marble throughout the whole house, two bedrooms and two full baths. Enjoy a concrete dock and davits with boat access to the Gulf and ocean in less than five minutes via the deep-water canal right outside your door. Enjoy access to a private community beach with picnic tables and tiki huts for fun barbecues; jet skiing; boat ramp and recreational boating and water skiing. Don't miss out on these .Located in a quiet neighborhood at Mile Marker 74 in Islamorada, this location is tastefully furnished, has a gourmet kitchen and is ideal for boaters.\n(hablamos español)    \nCall for appointment 305.467.6348 /  786.484.0917\nMarisol Acosta\nLicensed, Realtor Associate\nAkoya Realty LLC\nwww.akoyarealty.com") }
    its(:contents) {should eq("\u0095 $1,149,000.00                  <br>\n\u0095 2000ft²<br>\n\u0095 3-bedroom<br>\n\u0095 3-full bath<br><br>\nJUST REDUCED FOR A QUICK SALE!!!!<br><br>\nThis great Three Story 3-bedroom 3 Full bath home in Islamorada, Florida Keys is the perfect get-away to relax, enjoy the fresh breezes, the sandy beach and watch spectacular sunsets. A spacious master suite bedroom upstairs has a private bath with whirlpool Jacuzzi tub and private patio. Downstairs you have access to full kitchen custom cabinets, granite countertops, stainless steel appliances, open living-dining room, Travertine marble throughout the whole house, two bedrooms and two full baths. Enjoy a concrete dock and davits with boat access to the Gulf and ocean in less than five minutes via the deep-water canal right outside your door. Enjoy access to a private community beach with picnic tables and tiki huts for fun barbecues; jet skiing; boat ramp and recreational boating and water skiing. Don't miss out on these .Located in a quiet neighborhood at Mile Marker 74 in Islamorada, this location is tastefully furnished, has a gourmet kitchen and is ideal for boaters.<br><br>\n(hablamos español)    <br><br>\nCall for appointment 305.467.6348 /  786.484.0917<br>\nMarisol Acosta<br>\nLicensed, Realtor Associate<br>\nAkoya Realty LLC<br>\nwww.akoyarealty.com") }
  end
end
