require 'active_model'
require 'active_attr'
require 'active_attr/dirty'
require 'active_force/query'
require 'active_force/association'
require 'yaml'

module ActiveForce
  class SObject
    include ActiveAttr::Model
    include ActiveAttr::Dirty
    include ActiveForce::Association

    extend ClassMethods

    STANDARD_TYPES = %w[ Account Contact Opportunity Campaign]

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

    def self.has_many relation_name, options = {}
      super
      model = options[:model] || relation_model(relation_name)
      define_method relation_name do
        model.send_query(self.send "#{ relation_name }_query".to_sym)
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

    def self.query
      query = ActiveForce::Query.new(table_name)
      query.fields fields
      query
    end

    def self.all
      send_query query
    end

    def self.send_query query
      Client.query(query.to_s).to_a.map do |mash|
        build mash
      end
    end

    def self.find id
      send_query(query.find(id)).first
    end

    def update_attributes! attributes = {}
      assign_attributes attributes
      return false unless valid?
      sobject_hash = { 'Id' => id }
      changed.each do |field|
        sobject_hash[mappings[field.to_sym]] = read_attribute(field)
      end
      result = Client.update! table_name, sobject_hash
      changed_attributes.clear
      result
    end

    def update_attributes attributes = {}
      update_attributes! attributes
    rescue Faraday::Error::ClientError => error
      Rails.logger.info do
        "[SFDC] [#{self.class.model_name}] [#{self.class.table_name}] Error while updating, params: #{hash}, error: #{error.inspect}"
      end
      errors[:base] << error.message
      false
    end

    alias_method :update, :update_attributes

    def create!
      return false unless valid?
      hash = {}
      mappings.map do |field, name_in_sfdc|
        value = read_value field
        hash[name_in_sfdc] = value if value.present?
      end
      self.id = Client.create! table_name, hash
      changed_attributes.clear
    end

    def create
      create!
    rescue Faraday::Error::ClientError => error
      Rails.logger.info do
        "[SFDC] [#{self.class.model_name}] [#{self.class.table_name}] Error while creating, params: #{hash}, error: #{error.inspect}"
      end
      errors[:base] << error.message
      false
    end

    def save
      if persisted?
        update
      else
        create
      end
    end

    def to_param
      id
    end

    def persisted?
      id?
    end

    def self.field field_name, from: field_name.camelize, as: :string
      mappings[field_name] = from
      attribute field_name, sf_type: as
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
