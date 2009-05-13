require File.dirname(__FILE__) + "/index_view/sql_generator"
require File.dirname(__FILE__) + "/index_view/implementation"
require File.dirname(__FILE__) + "/index_view/customization_defaults"

class IndexView
  include Implementation
  include CustomizationDefaults

  ASC  = :ASC
  DESC = :DESC
  SORT_DIRECTIONS = [ASC, DESC]
  DEFAULT_PAGINATION_NUMBER = 30

  class InvalidSort < StandardError; end

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
  end
end
