require 'spec_helper'

describe CraigScrape::GeoListings do
  context "geolisting_iso_us_120412.html" do
    subject{ described_class.new uri_for('geolisting_iso_us_120412.html') }
    
    its(:location){should eq('united states') }
  end
end
