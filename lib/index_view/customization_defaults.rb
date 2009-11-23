module IndexView
  # The following methods are safe to override in descendent classes
  module CustomizationDefaults
    DEFAULT_PAGINATION_NUMBER = 30

    def target_class
      raise NotImplementedError
    end

    def per_page
      target_class.respond_to?(:per_page) ?
        target_class.per_page :
        DEFAULT_PAGINATION_NUMBER
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
  end
end
