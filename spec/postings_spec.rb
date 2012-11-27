require 'spec_helper'

describe CraigScrape::Posting do
  context "posting_mdc_cto_ftl_112612.html" do
    subject{ CraigScrape::Posting.new(
      uri_for('posting_mdc_cto_ftl_112612.html') ) }

    its(:title){should eq("1999 Mustang GT w/ '08 3 Valve Engine Swap")}
  end
end
