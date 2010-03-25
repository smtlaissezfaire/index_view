require File.expand_path(File.dirname(__FILE__) + "/../spec_helper")

module IndexView
  describe Base do
    before do
      @view = Class.new(IndexView::Base)
    end

    it "should be able to add a new column" do
      @view.column :foo
      column = @view.columns.first

      column.column_name.should equal(:foo)
    end
  end

  describe Base do
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
        Class.new(IndexView::Base) do
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

      describe "default_sort_term" do
        it "should raise a NotImplementedError by default" do
          model = new_index(User)

          lambda {
            model.default_sort_term
          }.should raise_error(NotImplementedError)
        end

        it "should sort by the default column" do
          scott = User.new(:first_name => "Scott", :last_name => "Taylor")
          bar = User.new(:first_name => "Foo",   :last_name => "Bar")

          scott.save!
          bar.save!

          klass = Class.new(IndexView::Base) do
            def default_sort_term
              :last_name
            end

            def default_sort_direction
              IndexView::Base::ASC
            end

            def target_class
              User
            end
          end

          klass.new.find(:all).should == [bar, scott]
        end
      end

      describe "pagination" do
        before(:each) do
          ar_class = Class.new(ActiveRecord::Base) do
            set_table_name :submissions
          end

          @index_class = Class.new(IndexView::Base) do
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

    describe "sorts" do
      class UserIndex < IndexView::Base; end

      it "should raise an error if the sort is = 'foo'" do
        @index = UserIndex.new({ :direction => "foo" })

        lambda {
          @index.sort_direction
        }.should raise_error(IndexView::InvalidSort, "FOO is not a valid sort direction")
      end

      it "should have the sort as 'ASC' when given 'asc'" do
        @index = UserIndex.new({ :direction => "asc" })
        @index.sort_direction.should == :ASC
      end

      it "should have the sort as 'DESC' when given 'desc'" do
        @index = UserIndex.new({ :direction => "desc" })
        @index.sort_direction.should == :DESC
      end

      it "should have ASC as the opposite sort order of DESC" do
        @index = UserIndex.new({ :direction => "DESC" })
        @index.opposite_sort_direction.should == :ASC
      end

      it "should have DESC as the opposite sort order of ASC" do
        @index = UserIndex.new({ :direction => "ASC" })
        @index.opposite_sort_direction.should == :DESC
      end
    end
  end
end
