require 'active_model'
require 'active_attr/dirty'
require 'active_force/active_query'
require 'active_force/association'
require 'active_force/table'
require 'active_force/attribute'
require 'yaml'
require 'forwardable'
require 'logger'

module ActiveForce
  class SObject
    include ActiveAttr::Model
    include ActiveAttr::Dirty
    include ActiveForce::Association
    extend ActiveModel::Callbacks

    define_model_callbacks :save, :create, :update

    class_attribute :mappings, :table_name

    class << self
      extend Forwardable
      def_delegators :query, :where, :first, :last, :all, :find, :find_by, :count
      def_delegators :table, :custom_table_name?
    end

    def self.table_name
      table.name
    end

    def self.table
      @table ||= ActiveForce::Table.new self
    end

    def self.fields
      mappings.map{|attr, sf_attr| sf_attr.from}
    end

    def self.query
      ActiveForce::ActiveQuery.new self
    end

    def self.build sf_table_description
      return unless sf_table_description
      sobject = new
      mappings.each do |attr, sf_field|
        sobject[attr] = sf_table_description[sf_field.from]
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

    def self.create args = {}
      new(args).save
    end

    def self.create! args = {}
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
      id?
    end

    def self.field field_name, args = {}
      mappings[field_name] = ActiveForce::Attribute.new(field_name, args)
      attribute field_name
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

    private

    def create!
      return false unless valid?
      self.id = sfdc_client.create! table_name, attributes_for_sfdb
      changed_attributes.clear
      self
    end
    ###
    # Provide each subclass with a default id field. Can be overridden
    # in the subclass if needed
    def self.inherited(subclass)
      subclass.field :id, from: 'Id'
    end

    def create
      run_callbacks :create do
        create!
      end
    end

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
      attrs = changed_mappings.map do |attr, attr_object|
        value = attr_object.value_for_hash
        [attr_object.from, value] if !value.empty?
      end
      attrs << ['Id', id] if persisted?
      Hash[attrs.compact]
    end

    def changed_mappings
      mappings.select { |attr, sf_field| changed.include? attr.to_s}
    end

    def sfdc_client
      self.class.sfdc_client
    end
  end

end
