require File.dirname(__FILE__) + "/index_view/column"
require File.dirname(__FILE__) + "/index_view/sql_generator"
require File.dirname(__FILE__) + "/index_view/sql_conditions"
require File.dirname(__FILE__) + "/index_view/implementation"
require File.dirname(__FILE__) + "/index_view/customization_defaults"

module IndexView
  class InvalidSort < StandardError; end

  class Base
    include Implementation
    include CustomizationDefaults

    class << self
      def find(*args)
        new({ }).find(*args)
      end

      def column(*args)
        columns << Column.new(*args)
      end

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
