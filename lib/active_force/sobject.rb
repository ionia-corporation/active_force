require 'active_model'
require 'active_attr'
require 'active_attr/dirty'

module ActiveForce
  class SObject
    include ActiveAttr::Model
    include ActiveAttr::Dirty

    # Types recognised don't get the added "__c"
    STANDARD_TYPES = %w[ Account Contact Opportunity ]

    class_attribute :mappings, :fields, :table_name

    # The table name to used to make queries.
    # It is derived from the class name adding the "__c" when needed.
    def self.table_name
      @table_name ||= if STANDARD_TYPES.include? self.name
                        self.name
                      else
                        "#{self.name}__c"
                      end
    end

    def self.build sobject
      return nil if sobject.nil?
      model = new
      mappings.each do |attr, sf_field|
        model[attr] = sobject[sf_field]
      end
      model.changed_attributes.clear
      model
    end

    def self.all
      all = Client.query(<<-SOQL.strip_heredoc).to_a
        SELECT
          #{ fields.join(', ') }
        FROM
          #{ table_name }
      SOQL
      all.map do |mash|
        build mash
      end
    end

    def self.find id
      build Client.query(<<-SOQL.strip_heredoc).first
        SELECT #{fields.join(', ')}
        FROM #{table_name}
        WHERE Id = '#{id}'
      SOQL
    end

    def self.create(attributes = nil, &block)
      if attributes.is_a?(Array)
        attributes.collect { |attr| create(attr, &block) }
      else
        object = new(attributes, &block)
        object.create
        object
      end
    end

    def create
      return false unless valid?
      hash = {}
      mappings.map do |field, name_in_sfdc|
        value = read_value field
        hash[name_in_sfdc] = value if value.present?
      end
      self.id = Client.create! table_name, hash
      changed_attributes.clear
    rescue Faraday::Error::ClientError => error
      Rails.logger.warn do
        "[SFDC] [#{self.class.model_name}] [#{self.class.table_name}] Error while creating, params: #{hash}, error: #{error.inspect}"
      end
      errors[:base] << error.message
      false
    end

    def update_attributes attributes
      assign_attributes attributes
      if valid?
        sobject_hash = { 'Id' => id }
        changed.each do |field|
          sobject_hash[mappings[field.to_sym]] = read_attribute(field)
        end
        result = Client.update table_name, sobject_hash
        changed_attributes.clear if result
        result
      else
        false
      end
    end

    def to_param
      id
    end

    def persisted?
      id?
    end

    def self.field field_name, from: field_name.camelize
      mappings[field_name] = from
      attribute field_name
    end

    def self.mappings
      @mappings ||= {}
    end

    private
      def read_value field
        if self.class.attributes[field][:sf_type] == :multi_picklist
          attribute(field.to_s).reject(&:empty?).join(';')
        else
          attribute(field.to_s)
        end
      end

      def self.picklist field
        picks = Client.picklist_values(table_name, mappings[field])
        picks.map do |value|
          [value[:label], value[:value]]
        end
      end
  end
end
