require File.expand_path(File.dirname(__FILE__) + "/../spec_helper")

module IndexView
  describe Column do
    it "should init with a column name" do
      Column.new(:foo).column_name.should == :foo
    end

    it "should symbolize the column name" do
      Column.new("bar").column_name.should == :bar
    end

    it "should allow a link method as a lambda" do
      Kernel.stub!(:warn)

      link = lambda {
        some_url
      }

      column = Column.new(:foo, :link => link)
      column.link.should == link
    end

    it "should raise a deprecation warning if receiving a :link key" do
      Kernel.should_receive(:warn)
      Column.new(:foo, :link => lambda {})
    end

    it "should allow a link method as a block" do
      link = lambda {
        some_url
      }

      column = Column.new(:foo, &link)
      column.link.should == link
    end

    it "should allow keys to be auto-symbolized" do
      column = Column.new(:foo, "title" => "foo")
      column.title.should == "foo"
    end

    it "should raise an error if an invalid key is given" do
      lambda {
        Column.new(:foo, :foo => :bar)
      }.should raise_error(Column::InvalidKeyError, "foo is not a valid key.  Valid keys are [:link, :sortable, :title, :searchable]")
    end

    it "should should raise the error with the correct key name" do
      lambda {
        Column.new(:foo, :bar => :baz)
      }.should raise_error(Column::InvalidKeyError, "bar is not a valid key.  Valid keys are [:link, :sortable, :title, :searchable]")
    end

    describe "url" do
      before(:each) do
        @column = Column.new(:foo) do
          some_link_url
        end
      end

      it "should evaluate the url in the environment given (not the one it's defined in)" do
        class AnotherContext
          def initialize(column)
            @column = column
          end

          def some_link_url
            "/foo/bar"
          end

          def column_value(object)
            @column.column_value(self, object)
          end
        end

        AnotherContext.new(@column).column_value(Object.new).should == "/foo/bar"
      end

      it 'should pass in the object given to the column value' do
        obj = Object.new

        column = Column.new(:foo) do
          obj
        end

        column.column_value(self, obj).should == obj
      end
    end

    describe "sorting" do
      it "should not be sortable by default" do
        Column.new(:foo).should_not be_sortable
      end

      it "should allow sorting if given true as the third param" do
        Column.new(:foo, :sortable => true).should be_sortable
      end

      it "should not allow sorting if given false as the third param" do
        Column.new(:foo, :sortable => false).should_not be_sortable
      end
    end

    describe "human_name" do
      it "should humanize the column name" do
        Column.new(:foo_bar).human_name.should == "Foo bar"
      end
    end

    describe "title" do
      it "should use the human name for the title" do
        Column.new(:foo_bar).title.should == "Foo bar"
      end

      it "should use the column title instead if specified" do
        Column.new(:foo_bar, :title => "FOO BAR").title.should == "FOO BAR"
      end
    end

    describe "searchable?" do
      it "should be true when passed :searchable => true" do
        Column.new(:foo_bar, :searchable => true).should be_searchable
      end

      it "should be false when passed :searchable => false" do
        Column.new(:foo_bar, :searchable => false).should_not be_searchable
      end

      it "should be false by default" do
        Column.new(:foo_bar).should_not be_searchable
      end
    end
  end
end
