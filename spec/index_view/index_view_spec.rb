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

describe IndexView do
  describe "defaults" do
    def new_mock_class
      Class.new do
        def self.table_name
          "foobar"
        end

        def self.set_table_name(name)
        end
      end
    end

    def new_index(model, attributes={ })
      Class.new(IndexView) do
        define_method :target_class do
          model
        end
      end.new(attributes)
    end

    describe "table_name" do
      it "should use the model's table name, symbolized" do
        model = new_mock_class
        index = new_index(model)
        index.table_name.should == :foobar
      end
    end

    describe "per_page" do
      it "should use the per page value of the class" do
        model = new_mock_class
        model.stub!(:per_page).and_return 50

        index = new_index(model)
        index.per_page.should == 50
      end

      it "should use 30 if none is provided" do
        model = new_mock_class

        index = new_index(model)
        index.per_page.should == 30
      end
    end

    describe "fields_for_search" do
      it "should be an empty array when none provided" do
        model = new_mock_class
        model.stub!(:per_page).and_return 50

        index = new_index(model)
        index.fields_for_search.should == []
      end
    end

    describe "default_sort_direction" do
      it "should be DESC" do
        model = new_mock_class
        model.stub!(:per_page).and_return 50

        index = new_index(model)
        index.default_sort_direction.should == :DESC
      end
    end

    describe "pagination" do

      before(:each) do
        ar_class = Class.new(ActiveRecord::Base) do
          set_table_name :submissions
        end

        @index_class = Class.new(IndexView) do
          define_method :ar_class do
            ar_class
          end

          def target_class
            ar_class
          end

          def default_sort_term
            ""
          end

          def fields_for_search
            [:foo, :bar]
          end
        end
      end

      it "should paginate with the page param given" do
        index = @index_class.new(:page => 17)
        index.pagination_options.should include(:page => 17)
      end

      it "should add a state condition when given" do
        index = @index_class.new(:state => "foo")
        index.pagination_options.should include(:conditions => "(state = 'foo')")
      end

      it "should use the correct state name" do
        index = @index_class.new(:state => "bar")
        index.pagination_options.should include(:conditions => "(state = 'bar')")
      end

      it "should use a search term as well as a state name" do
        index = @index_class.new(:state => "bar", :search => "foo")
        conditions = index.pagination_options[:conditions]

        conditions.should =~ /state = \'bar\'/
        conditions.should =~ /\(foo LIKE '%foo%' OR bar LIKE '%foo%'\)/
      end

      it "should include any conditions given by the derivative class in the index hash" do
        index = @index_class.new(:index => { :foo => "bar" })
        index.pagination_options[:conditions].should == "(foo = 'bar')"
      end

      it "should skip conditions in the index hash which are empty" do
        index = @index_class.new(:index => { :foo => "" })
        index.pagination_options[:conditions].should == ""
      end
    end
  end

  describe "using the target class" do
    before(:each) do
      @index = new_mock_index_class.new(:setup_class => false)
    end

    def new_mock_index_class
      Class.new(IndexView) do
        def target_class
          User
        end

        def table_name
          :users_index
        end
      end
    end

    it "should yield the target class" do
      klass = nil

      @index.use_class do |k|
        klass = k
      end

      klass.should == User
    end

    it "should use the table name given by the index" do
      table_name = nil

      @index.use_class do |klass|
        table_name = klass.table_name
      end

      table_name.should == "users_index"
    end

    it "should have the User's table_name as 'users'" do
      @index.use_class { }
      User.table_name.should == "users"
    end

    it "should not change the User's table_name" do
      lambda {
        @index.use_class { }
      }.should_not change(User, :table_name)
    end

    it "should restore the table name even if the block raises" do
      begin
        @index.use_class do
          raise
        end
      rescue; end

      User.table_name.should == "users"
    end

    it "should restore the table name even if the block an Exception" do
      begin
        @index.use_class do
          raise Exception
        end
      rescue Exception; end

      User.table_name.should == "users"
    end
  end
end
