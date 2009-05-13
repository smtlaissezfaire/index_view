module IndexView
  module SQLGenerator
    def like_for_many_columns(value, *fields)
      [
        condition_fields_for_like_with_many_columns(value, fields), 
        *value_fields_for_like_with_many_columns(value, fields)
      ]
    end
    
  private
    
    def condition_fields_for_like_with_many_columns(value, fields)
      fields.map { |field| "#{field} LIKE ?" }.join(" OR ")
    end

    def value_fields_for_like_with_many_columns(value, fields)
      fields.map { "%#{value}%" }
    end
  end
end