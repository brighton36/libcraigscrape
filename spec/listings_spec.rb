require 'spec_helper'

describe CraigScrape::Listings do
  describe '#posts' do
    context "listing_cta_ftl_112612.html" do
      let(:listing) { described_class.new( uri_for('listing_cta_ftl_112612.html') ) }
      specify{ listing.posts.should have(100).items }
    end
  end 
end
