require 'active_force/standard_types'

module ActiveForce
  class Table

    def initialize klass
      @klass = klass.to_s
    end

    def table_name name = nil
      @name = name || @name || pick_table_name
    end

    def name
      @name ||= pick_table_name
    end

    def custom_table?
      !StandardTypes::STANDARD_TYPES.include?(name_without_namespace)
    end

    private

    def pick_table_name
      if custom_table?
        "#{ name_without_namespace }__c"
      else
        name_without_namespace
      end
    end

    def name_without_namespace
       @klass.split('::').last
    end

  end
end
