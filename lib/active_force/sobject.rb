require 'active_model'
require 'active_attr'
require 'active_attr/dirty'
require 'active_force/active_query'
require 'active_force/association'
require 'yaml'

module ActiveForce
  class SObject
    include ActiveAttr::Model
    include ActiveAttr::Dirty
    include ActiveForce::Association

    STANDARD_TYPES = %w[ Account Contact Opportunity Campaign]

    class_attribute :mappings, :fields, :table_name

    class << self
      delegate :where, :first, :last, :all, :find, :find_by, :count, :to => :query
    end

    # The table name to used to make queries.
    # It is derived from the class name adding the "__c" when needed.
    def self.table_name
      @table_name ||= custom_table_name || "#{ self.name }__c"
    end

    def self.build sf_table_description
      return unless sf_table_description
      sobject = new
      mappings.each do |attr, sf_field|
        sobject[attr] = sf_table_description[sf_field]
      end
      sobject.changed_attributes.clear
      sobject
    end

    def self.query
      ActiveForce::ActiveQuery.new self
    end

    def update_attributes! attributes = {}
      assign_attributes attributes
      return false unless valid?
      sobject_hash = { 'Id' => id }
      changed.each do |field|
        sobject_hash[mappings[field.to_sym]] = read_attribute(field)
      end
      result = sfdc_client.update! table_name, sobject_hash
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
      self.id = sfdc_client.create! table_name, hash
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

    def self.custom_table_name
      self.name if STANDARD_TYPES.include? self.name
    end

      def read_value field
        if self.class.attributes[field][:sf_type] == :multi_picklist
          attribute(field.to_s).reject(&:empty?).join(';')
        else
          attribute(field.to_s)
        end
      end

      def self.picklist field
        picks = sfdc_client.picklist_values(table_name, mappings[field])
        picks.map do |value|
          [value[:label], value[:value]]
        end
      end

      def self.sfdc_client
        Client
      end

      def sfdc_client
        self.class.sfdc_client
      end
  end
end
