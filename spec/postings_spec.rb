require 'spec_helper'

describe CraigScrape::Posting do
  context "this_post_has_expired_old" do
    subject{ CraigScrape::Posting.new(
      uri_for('this_post_has_expired_old.html') ) }
 
    its(:posting_has_expired?){ should be_true }
  end

  context "posting_mdc_cto_ftl_112612.html" do
    subject{ CraigScrape::Posting.new(
      uri_for('posting_mdc_cto_ftl_112612.html') ) }

    its(:title)    {should eq("1999 Mustang GT w/ '08 3 Valve Engine Swap")}
    its(:contents) {should eq("I am selling my 1999 Mustang GT with a 2008 GT 3 Valve engine swap. The car is a 5 speed with 3.73 rear gears. It has a Diablo Sport chip with 2 tunes. The rear tires have plentyt of tread and are Michelin Pilot sports ($700 less than a year ago). The rims are staggered and are less than a year old. The car has a 2003 Mustang Cobra hood. It also has a 2003 Cobra front bumper. The paint on the car is less than a year old. The bad: The car will need 2 front tires soon. They are currently Nitto 555's. The A/C Compressor will need changing soon as it is making a little noise. It works but I dont use it just in case. The drivers side seat needs to be re-upholstered also. Minor problems considering the work that went into this car. The instrument cluster is from a Mach 1 and shows 120,000 miles, but the engine has around 70,000 miles. <br><br>\nA lot of time and money was spent on this car to do the swap right. It is my daily driver and has never given me a single problem. It's always had Mobil 1 Synthetic oil and it's plenty fast and a lot of fun to drive. If you are looking for something unique and you are a Mustang fan, you might want to consider this car.<br><br>\nThe seats are from a newer model Mustang GT. The car runs really good, and turns heads everywhere it goes, especially when I pop the hood and those in the know see the engine that doesnt belong there.  : )<br><br>\nI am will consider all offers so please don't be shy, the worse that I can do is say no. I am interested in some specific cars as well that I willl consider on trade. BMW 530 or 540, Infinity G35, Lexus IS 300 or GS300 or 400. I respond better to texts or emails. Call with any quesrtions. 305-310-5993 or email me at Torresa76@aol.com<br><br>\nThanks for looking.  : )")}
  end
end
