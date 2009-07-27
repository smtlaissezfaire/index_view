require File.expand_path(File.dirname(__FILE__) + "/../spec_helper")

class UserIndex < IndexView::Base
  column :first_name,
         :title => "First Name"
  column :last_name,
         :title => "Last Name"
  column :email,
         :link => lambda { |obj| "<a mailto:#{obj.email}>me</a>" }
  
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
end