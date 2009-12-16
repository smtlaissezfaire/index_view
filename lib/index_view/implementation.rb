module IndexView
  module Implementation
    include SQLConditions

    ASC                       = :ASC
    DESC                      = :DESC
    SORT_DIRECTIONS           = [ASC, DESC]

    attr_reader :params

    def initialize(params = { })
      @params = params
    end

    def paginate
      target_class.paginate(pagination_options)
    end

    def find(selector, options={})
      case selector
      when :first, :last, :all
        target_class.find(selector, find_options.merge(options))
      else
        target_class.find(selector)
      end
    end

    def find_options
      {
        :from       => table_name.to_s,
        :order      => sort,
        :conditions => conditions_sql
      }
    end

    def pagination_options
      {
        :from       => table_name.to_s,
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
        raise IndexView::InvalidSort, "#{given_sort_direction} is not a valid sort direction"
      end
    end

    def opposite_sort_direction
      ascending? ? DESC : ASC
    end

    def columns
      self.class.columns
    end

    def sorting?(column_name)
      sort_term.to_s == column_name.to_s
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

    def fields_for_search
      self.class.fields_for_search
    end

    def table_name
      target_class.table_name.to_sym
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
      target_class.send(:sanitize_sql, sql)
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
