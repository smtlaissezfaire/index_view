require File.dirname(__FILE__) + "/index/implementation"
require File.dirname(__FILE__) + "/index/customization_defaults"

class Index
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
