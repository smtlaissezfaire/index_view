module IndexView
  class Column
    class InvalidKeyError < StandardError; end

    OPTION_KEYS = [:link, :sortable, :title, :searchable]

    def initialize(column_name, options={ }, &link)
      @column_name = column_name.to_sym

      check_and_assign_values_from_keys(options, link)
    end

    attr_reader :column_name, :link

    def column_value(context, object)
      context.instance_exec(object, &link)
    end

    def column_value?
      link ? true : false
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

    def searchable?
      @searchable ? true : false
    end

  private

    def check_and_assign_values_from_keys(hash, link)
      hash.each do |key, value|
        key = key.to_sym

        if key == :link
          Kernel.warn ":link is no longer a valid key.  Pass a block directly to the column method (from #{caller[5]})"
        end

        if OPTION_KEYS.include?(key)
          assign_if_present(key, value)
        else
          key_names = "[#{OPTION_KEYS.map { |k| ":#{k}" }.join(", ")}]"
          raise InvalidKeyError, "#{key} is not a valid key.  Valid keys are #{key_names}"
        end
      end

      assign_if_present(:link, link)
    end

    def assign_if_present(key, value)
      instance_variable_set("@#{key}", value) if value
    end
  end
end
