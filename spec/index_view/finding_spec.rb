require File.expand_path(File.dirname(__FILE__) + "/../spec_helper")

module IndexView
  class MockView < IndexView::Base
    def target_class
      User
    end

    def table_name
      :users_index
    end
  end

  describe "finding" do
    it "should find using the correct table name" do
      User.should_receive(:find).with(:first, :from => "users_index")
      MockView.find(:first)
    end

    it "should merge the second list of options" do
      User.should_receive(:find).with(:first, :from => "users_index", :conditions => "foo = 'bar'")
      MockView.find(:first, :conditions => "foo = 'bar'")
    end

    it "should pass the correct selector" do
      User.should_receive(:find).with(:all, :from => "users_index")
      MockView.find(:all)
    end
  end
end