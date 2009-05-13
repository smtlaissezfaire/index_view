class IndexView
  module Implementation
    include SQLConditions
    
    attr_reader :params

    def initialize(params = { })
      @params = params
    end

    def paginate
      use_class do |klass|
        klass.paginate pagination_options
      end
    end
  
    def find(*args)
      use_class do |klass|
        klass.find(*args)
      end
    end

    def use_class
      original_name = target_class.table_name

      target_class.set_table_name(table_name.to_s)
      yield target_class
    ensure
      target_class.set_table_name(original_name)
    end
  
    def pagination_options
      {
        :conditions => conditions_sql,
        :order      => sort,
        :page       => @params[:page],
        :per_page   => per_page
      }
    end
  
    def search_term
      @params[:search]
    end
  
    def search_term?
      search_term && !search_term.blank? ? true : false
    end
  
    def sort
      "#{sort_term} #{sort_direction}" + (!secondary_sort_term.blank? ? ", #{secondary_sort_term} #{sort_direction}" : '')
    end
  
    def sort_term
      @params[:sort] || default_sort_term
    end
  
    def sort_direction
      if SORT_DIRECTIONS.include?(given_sort_direction)
        given_sort_direction
      else
        raise InvalidSort, "#{given_sort_direction} is not a valid sort direction"
      end
    end
  
    def opposite_sort_direction
      ascending? ? DESC : ASC
    end
  
    def columns
      self.class.columns
    end
  
    def ascending?
      sort_direction == ASC
    end
  
    def descending?
      !ascending?
    end

    def state?
      state && !state.blank? ? true : false
    end

    def state
      @params[:state]
    end
    
  private

    def conditions_sql
      present_conditions.join(" AND ")
    end

    def present_conditions
      parenthesize(remove_empties(sanitize(conditions)))
    end

    def conditions
      [search_conditions, state_conditions, *index_parameter_conditions]
    end

    def index_parameter_conditions
      if index_params = params[:index]
        index_params.reject { |k,v| v.blank? }.map { |k, v| ["#{k} = ?", v] }
      end
    end

    def parenthesize(collection)
      collection.map { |element| "(#{element})" }
    end

    def remove_empties(collection)
      collection.reject { |element| element.blank? }
    end

    def sanitize(collection)
      collection.map { |element| sanitize_sql(element) }
    end

    def sanitize_sql(sql)
      ActiveRecord::Base.send(:sanitize_sql, sql)
    end
  
    def given_sort_direction
      if direction = @params[:direction]
        direction.upcase.to_sym
      else
        default_sort_direction
      end
    end
  end
end
