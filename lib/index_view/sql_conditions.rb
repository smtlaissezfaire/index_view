module IndexView
  module SQLConditions
    include SQLGenerator
  
  private
  
    def state_conditions
      if state?
        ["state = ?", state]
      end
    end

    def search_conditions
      if search_term?
        like_for_many_columns(search_term, *fields_for_search)
      end
    end
  end
end