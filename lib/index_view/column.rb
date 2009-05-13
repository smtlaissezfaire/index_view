module IndexView
  class Column
    class InvalidKeyError < StandardError; end

    OPTION_KEYS = [:link, :sortable, :title]

    def initialize(column_name, options={ })
      @column_name = column_name.to_sym

      check_and_assign_values_from_keys(options)
    end

    attr_reader :column_name, :link
    alias_method :link_method, :link

    def column_value(context, object)
      context.instance_exec(object, &link_method)
    end

    def column_value?
      link_method ? true : false
    end

    def sortable?
      @sortable ? true : false
    end

    def human_name
      column_name.to_s.humanize
    end

    def title
      @title ? @title : human_name
    end

  private

    def check_and_assign_values_from_keys(hash)
      hash.each do |key, value|
        key = key.to_sym

        if OPTION_KEYS.include?(key)
          assign_if_present(key, value)
        else
          key_names = "[#{OPTION_KEYS.map { |k| ":#{k}" }.join(", ")}]"
          raise InvalidKeyError, "#{key} is not a valid key.  Valid keys are #{key_names}"
        end
      end
    end

    def assign_if_present(key, value)
      instance_variable_set("@#{key}", value) if value
    end
  end
end