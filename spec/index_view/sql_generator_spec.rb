require File.dirname(__FILE__) + "/../spec_helper"

describe IndexView::SQLGenerator do
  it "should be a module" do
    IndexView::SQLGenerator.should be_a_kind_of(Module)
  end
end