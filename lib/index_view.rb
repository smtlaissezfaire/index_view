require File.dirname(__FILE__) + "/index_view/column"
require File.dirname(__FILE__) + "/index_view/sql_generator"
require File.dirname(__FILE__) + "/index_view/sql_conditions"
require File.dirname(__FILE__) + "/index_view/implementation"
require File.dirname(__FILE__) + "/index_view/customization_defaults"

module IndexView
  module Version
    MAJOR = 0
    MINOR = 1
    TINY  = 0

    STRING = "#{MAJOR}.#{MINOR}.#{TINY}"
  end

  class InvalidSort < StandardError; end

  class Base
    include Implementation
    include CustomizationDefaults

    class << self
      def find(*args)
        new({}).find(*args)
      end

      def all(*args)
        new({}).all(*args)
      end

      def first(*args)
        new({}).first(*args)
      end

      # used to define columns you want to render in the view,
      # and gives you a way to customize _how_ they render
      # See IndexView::Column to get an idea of the options you can pass in.
      def column(*args, &block)
        columns << Column.new(*args, &block)
      end

      # returns a collection of the IndexView::Column objects that were
      # added through the +column+ method
      def columns
        @columns ||= []
      end

      def fields_for_search
        searchable_columns = columns.select { |c| c.searchable? }
        searchable_columns.map { |col| col.column_name }
      end
    end
  end
end
