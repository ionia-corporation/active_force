require 'active_model'
require 'active_attr'
require 'active_attr/dirty'
require 'active_force/active_query'
require 'active_force/association'
require 'active_force/table'
require 'yaml'
require 'forwardable'
require 'logger'
require 'restforce'

module ActiveForce
  class SObject
    include ActiveAttr::Model
    include ActiveAttr::Dirty
    extend ActiveForce::Association
    extend ActiveModel::Callbacks

    define_model_callbacks :save, :create, :update

    class_attribute :mappings, :table_name

    class << self
      extend Forwardable
      def_delegators :query, :where, :first, :last, :all, :find, :find_by, :count, :includes
      def_delegators :mapping, :table, :table_name, :custom_table?

      private

      ###
      # Transforms +attribute+ to the conventional Salesforce API name.
      #
      # Example:
      #   > default_api_name :some_attribute
      #   => "Some_Attribute__c"
      def default_api_name(attribute)
        String(attribute).split('_').map(&:capitalize).join('_') << '__c'
      end

      ###
      # Provide each subclass with a default id field. Can be overridden
      # in the subclass if needed
      def inherited(subclass)
        subclass.field :id, from: 'Id'
      end
    end

    def self.mapping
      @mapping ||= ActiveForce::Mapping.new name
    end

    def self.fields
      mappings.values
    end

    def self.query
      ActiveForce::ActiveQuery.new self
    end

    def self.build mash
      return unless mash
      sobject = new
      mash.each do |column, sf_value|
        sobject.write_value column, sf_value
      end
      sobject.changed_attributes.clear
      sobject
    end

    def update_attributes! attributes = {}
      assign_attributes attributes
      return false unless valid?
      sfdc_client.update! table_name, attributes_for_sfdb
      changed_attributes.clear
      self
    end

    def update_attributes attributes = {}
      run_callbacks :update do
        update_attributes! attributes
      end
    rescue Faraday::Error::ClientError => error
      logger_output __method__
    end

    alias_method :update, :update_attributes

    def create!
      return false unless valid?
      self.id = sfdc_client.create! table_name, attributes_for_sfdb
      changed_attributes.clear
      self
    end

    def create
      run_callbacks :create do
        create!
      end
    rescue Faraday::Error::ClientError => error
      logger_output __method__
    end

    def destroy
      sfdc_client.destroy! self.class.table_name, id
    end

    def self.create args
      new(args).save
    end

    def self.create! args
      new(args).save!
    end

    def save
      run_callbacks :save do
        if persisted?
          update
        else
          create
        end
      end
    end

    def save!
      save
    rescue Faraday::Error::ClientError => error
      logger_output __method__
    end

    def to_param
      id
    end

    def persisted?
      !!id
    end

    def self.field field_name, args = {}
      args[:from] ||= default_api_name(field_name)
      args[:as]   ||= :string
      mappings[field_name] = args[:from]
      attribute field_name, sf_type: args[:as]
    end

    def self.mappings
      @mappings ||= {}
    end

    def reload
      association_cache.clear
      reloaded = self.class.find(id)
      self.attributes = reloaded.attributes
      changed_attributes.clear
      self
    end

    #TODO: read_value and write_value should have more descriptive names.
    def read_value field
      case sf_field_type field
      when :multi_picklist
        attribute(field.to_s).reject(&:empty?).join(';')
      else
        attribute(field.to_s)
      end
    end

    def write_value column, value
      if value.is_a? Hash and self.class.find_association column
        association = self.class.find_association column
        field = association.relation_name
        value = association.relation_model.build value
      else
        field = mappings.invert[column]
      end
      send "#{field}=", value if field
    end

   private

    def association_cache
      @association_cache ||= {}
    end

    def logger_output action
      logger = Logger.new(STDOUT)
      logger.info("[SFDC] [#{self.class.model_name}] [#{self.class.table_name}] Error while #{ action }, params: #{hash}, error: #{error.inspect}")
      errors[:base] << error.message
      false
    end

    def attributes_for_sfdb
      if persisted?
        attrs = changed_mappings.map do |attr, sf_field|
          value = read_value(attr)
          [sf_field, value]
        end
        attrs << ['Id', id]
      else
        attrs = mappings.map do |attr, sf_field|
          value = read_value(attr)
          [sf_field, value] unless value.nil?
        end
      end
      Hash[attrs.compact]
    end

    def changed_mappings
      mappings.select { |attr, sf_field| changed.include? attr.to_s}
    end

    def sf_field_type field
      self.class.attributes[field][:sf_type]
    end

    def self.picklist field
      picks = sfdc_client.picklist_values(table_name, mappings[field])
      picks.map do |value|
        [value[:label], value[:value]]
      end
    end

    def self.sfdc_client
      @client ||= Restforce.new
    end

    def sfdc_client
      self.class.sfdc_client
    end
  end

end
