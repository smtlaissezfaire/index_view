module IndexView
  # The following methods are safe to override in descendent classes
  module CustomizationDefaults
    DEFAULT_PAGINATION_NUMBER = 30
    
    def target_class
      raise NotImplementedError
    end

    def table_name
      target_class.table_name.to_sym
    end

    def per_page
      use_class do |klass|
        klass.respond_to?(:per_page) ?
          klass.per_page :
          DEFAULT_PAGINATION_NUMBER
      end
    end

    def default_sort_term
      raise NotImplementedError
    end

    def secondary_sort_term
      nil
    end

    def default_sort_direction
      Implementation::DESC
    end

    def fields_for_search
      []
    end
  end
end
