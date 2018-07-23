require 'active_force/field'
require 'active_force/table'
require 'forwardable'

module ActiveForce
  class Mapping
    extend Forwardable

    def_delegators :table, :custom_table?, :table_name

    def initialize model
      @model = model
    end

    def mappings
      Hash[fields.map { |field, attr| [field, attr.sfdc_name] }]
    end

    def sfdc_names
      mappings.values
    end

    def field name, options
      fields.merge!({ name => ActiveForce::Field.new(name, options) })
    end

    def table
      @table ||= ActiveForce::Table.new @model
    end

    def translate_to_sf attributes
      attrs = attributes.map do |attribute, value|
        field = fields[attribute.to_sym]
        [field.sfdc_name, field.value_for_hash(value)]
      end
      Hash[attrs]
    end

    def translate_value value, field_name
      return value unless !!field_name
      value
    end


    private

    def fields
      @fields ||= {}
    end

  end
end
