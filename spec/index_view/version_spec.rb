require "spec_helper"

describe IndexView::Version do
  it "should be at 0.1.0" do
    IndexView::Version::STRING.should == "0.1.0"
  end
end