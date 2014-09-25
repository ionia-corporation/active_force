require 'active_model'
require 'active_attr'
require 'active_attr/dirty'
require 'active_force/active_query'
require 'active_force/association'
require 'active_force/mapping'
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
      def_delegators :mapping, :table, :table_name, :custom_table?, :mappings

      private

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
      mapping.sfdc_names
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
      logger_output __method__, error, attributes
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
      logger_output __method__, error, attributes_for_sfdb
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
      logger_output __method__, error, attributes_for_sfdb
    end

    def to_param
      id
    end

    def persisted?
      !!id
    end

    def self.field field_name, args = {}
      mapping.field field_name, args
      attribute field_name
    end

    def reload
      association_cache.clear
      reloaded = self.class.find(id)
      self.attributes = reloaded.attributes
      changed_attributes.clear
      self
    end

    def write_value column, value
      if [Hash, Array, NilClass].include?(value.class) and association = self.class.find_association(column)
        field = association.relation_name
        value = case value
        when Hash; association.relation_model.build value
        when Array; value.map { |mash| association.relation_model.build mash }
        when NilClass; []
        end
      else
        field = mappings.invert[column]
        value = self.class.mapping.translate_value value, field unless value.nil?
      end
      send "#{field}=", value if field
    end

   private

    def association_cache
      @association_cache ||= {}
    end

    def logger_output action, exception, params = {}
      logger = Logger.new(STDOUT)
      logger.info("[SFDC] [#{self.class.model_name}] [#{self.class.table_name}] Error while #{ action }, params: #{params}, error: #{exception.inspect}")
      errors[:base] << exception.message
      false
    end

    def attributes_for_sfdb
      attrs = self.class.mapping.translate_to_sf(attributes_and_changes)
      attrs.merge!({'Id' => id }) if persisted?
      attrs
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
