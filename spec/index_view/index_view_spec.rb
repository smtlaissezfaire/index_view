require File.dirname(__FILE__) + "/../spec_helper"

describe IndexView do
  before do
    @view = Class.new(IndexView)
  end
  
  it "should be able to add a new column" do
    @view.column :foo
    column = @view.columns.first
    
    column.column_name.should equal(:foo)
  end
end