require File.expand_path(File.dirname(__FILE__) + "/../spec_helper")

module IndexView
  class MockView < IndexView::Base
    def target_class
      User
    end

    def table_name
      :users_index
    end

    def sort_term
      "foo"
    end

    def sort_direction
      "DESC"
    end
  end

  describe "finding" do
    it "should find using the correct table name" do
      User.should_receive(:find).with(:first, hash_including(:from => "users_index"))
      MockView.find(:first)
    end

    it "should merge the second list of options" do
      User.should_receive(:find).with(:first, hash_including(:from => "users_index", :conditions => "foo = 'bar'"))
      MockView.find(:first, :conditions => "foo = 'bar'")
    end

    it "should pass the correct selector" do
      User.should_receive(:find).with(:all, hash_including(:from => "users_index"))
      MockView.find(:all)
    end

    it "should pass in the order condition" do
      User.should_receive(:find).with(:all, hash_including(:order => "foo DESC"))
      MockView.find(:all)
    end

    it "should pass in the sql conditions" do
      view = MockView.new({:index => {:bar => "baz"}})

      User.should_receive(:find).with(:all, hash_including(:conditions => "(bar = 'baz')"))
      view.find(:all)
    end

    it "should be able to find by id" do
      User.should_receive(:find).with(1)
      MockView.find(1)
    end

    it "should use the correct id when finding by id" do
      User.should_receive(:find).with(2)
      MockView.find(2)
    end

    it "should find with all + default actions" do
      User.should_receive(:find).with(:all, {:order => "foo DESC", :from => "users_index", :conditions => ""}).and_return nil
      MockView.all
    end
  end

  class SearchableView < IndexView::Base
    column :first_name, :searchable => true

    def target_class
      User
    end

    def sort_term
      :first_name
    end

    def sort_direction
      "DESC"
    end
  end

  describe "searching" do
    before do
      @params = {}
      @controller = mock 'controller', :params => @params
    end

    it "should find an exact match against a searchable column" do
      user = User.new
      user.first_name = "scott"
      user.save!

      @params[:search] = "scott"

      view = SearchableView.new(@params)
      view.find(:all).should == [user]
    end

    it "should not find a user who doesn't match" do
      user = User.new
      user.first_name = "stephen"
      user.save!

      @params[:search] = "scott"

      view = SearchableView.new(@params)
      view.find(:all).should == []
    end

    it "should find a user who matches a like" do
      user = User.new
      user.first_name = "scott"
      user.save!

      @params[:search] = "cot"

      view = SearchableView.new(@params)
      view.find(:all).should == [user]
    end

    it "should replace spaces with %'s" do
      user = User.new
      user.first_name = "scott      A"
      user.save!

      @params[:search] = "scott A"

      view = SearchableView.new(@params)
      view.find(:all).should == [user]
    end
  end
end
