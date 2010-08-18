require File.expand_path(File.dirname(__FILE__) + "/../spec_helper")

class UserIndex < IndexView::Base
  column :first_name,
         :title => "First Name",
         :searchable => true
  column :last_name,
         :title => "Last Name"
  column :email do |obj|
    "<a mailto:#{obj.email}>me</a>"
  end

  def target_class
    User
  end

  def default_sort_term
    :first_name
  end
end

describe IndexView, "integration" do
  before do
    @index = UserIndex.new
  end

  def create_user(attributes)
    User.create!(attributes)
  end

  it "should have the columns for a pagination" do
    user = create_user(:first_name => "Scott", :last_name => "Taylor")
    row = UserIndex.find(:first)

    row.first_name.should == "Scott"
    row.last_name.should  == "Taylor"
  end

  it "should have the index column titles" do
    @index.columns.map { |r| r.title }.should == ["First Name", "Last Name", "Email"]
  end

  it "should allow a proc as the link method" do
    user = create_user(:email => "scott@railsnewbie.com")
    @row = UserIndex.find(:first)

    column = UserIndex.columns.detect { |c| c.column_name == :email }

    column.column_value(self, user).should == "<a mailto:scott@railsnewbie.com>me</a>"
  end

  it "should add a column with :searchable => true as a field for search" do
    @index.fields_for_search.should == [:first_name]
  end

  it "should raise a deprecation warning if receiving a :link key" do
    Kernel.should_receive(:warn).with(":link is no longer a valid key.  Pass a block directly to the column method (from #{__FILE__}:#{__LINE__+3})")

    Class.new(IndexView::Base) do
      column :foo, :link => lambda { }
    end
  end
end
