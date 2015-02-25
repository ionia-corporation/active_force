require 'active_force/attribute'
require 'active_force/table'
require 'forwardable'

module ActiveForce
  class Mapping
    extend Forwardable

    STRINGLIKE_TYPES = [
      nil, :string, :base64, :byte, :ID, :reference, :currency, :textarea,
      :phone, :url, :email, :combobox, :picklist, :multipicklist, :anyType,
      :location
    ]

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
      fields.merge!({ name => ActiveForce::Attribute.new(name, options) })
    end

    def table
      @table ||= ActiveForce::Table.new @model
    end

    def translate_to_sf attributes
      attrs = attributes.map do |attribute, value|
        attr = fields[attribute.to_sym]
        [attr.sfdc_name, attr.value_for_hash(value)]
      end
      Hash[attrs]
    end

    def translate_value value, field_name
      return value unless !!field_name
      typecast_value value, fields[field_name].as
    end


    private

    def fields
      @fields ||= {}
    end

    # Handles Salesforce FieldTypes as described here:
    # http://www.salesforce.com/us/developer/docs/api/Content/sforce_api_calls_describesobjects_describesobjectresult.htm#i1427700
    def typecast_value value, type
      case type
      when *STRINGLIKE_TYPES
        value.to_s
      when :boolean
        !['false','0','f'].include? value.downcase
      when :int
        value.to_i
      when :double, :percent
        value.to_f
      when :date
        Date.parse value
      when :datetime
        DateTime.parse value
      else
        value
      end
    end
  end
end
