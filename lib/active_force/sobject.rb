require 'active_model'
require 'active_attr'
require 'active_attr/dirty'
require 'active_force/active_query'
require 'active_force/association'
require 'active_force/persistence'
require 'yaml'
require 'forwardable'
require 'logger'
require 'active_force/standard_types'

module ActiveForce
  class SObject
    include ActiveAttr::Model
    include ActiveAttr::Dirty
    include ActiveForce::Association
    include ActiveForce::Persistence
    extend ActiveModel::Callbacks

    define_model_callbacks :save, :create, :update

    class_attribute :mappings, :table_name

    class << self
      extend Forwardable
      def_delegators :query, :where, :first, :last, :all, :find, :find_by, :count

      def custom_table_name?
        !StandardTypes::STANDARD_TYPES.include?(name_without_namespace)
      end

      # The table name to used to make queries.
      # It is derived from the class name adding the "__c" when needed.
      def table_name
        @table_name ||= pick_table_name
      end

      def fields
        mappings.values
      end

      def query
        ActiveForce::ActiveQuery.new self
      end

      def field field_name, args = {}
        args[:from] ||= default_api_name(field_name)
        args[:as]   ||= :string
        mappings[field_name] = args[:from]
        attribute field_name, sf_type: args[:as]
      end

      def mappings
        @mappings ||= {}
      end

      def sfdc_client
        @client ||= Restforce.new
      end

      private

      def picklist field
        picks = sfdc_client.picklist_values(table_name, mappings[field])
        picks.map do |value|
          [value[:label], value[:value]]
        end
      end

      ###
      # Transforms +attribute+ to the conventional Salesforce API name.
      #
      # Example:
      #   > default_api_name :some_attribute
      #   => "Some_Attribute__c"
      def default_api_name(attribute)
        String(attribute).split('_').map(&:capitalize).join('_') << '__c'
      end

      def pick_table_name
        if custom_table_name?
          "#{name_without_namespace}__c"
        else
          name_without_namespace
        end
      end

      def name_without_namespace
        name.split('::').last
      end

      ###
      # Provide each subclass with a default id field. Can be overridden
      # in the subclass if needed
      def inherited(subclass)
        subclass.field :id, from: 'Id'
      end
    end

    def to_param
      id
    end

    private

    def logger_output action
      logger = Logger.new(STDOUT)
      logger.info("[SFDC] [#{self.class.model_name}] [#{self.class.table_name}] Error while #{ action }, params: #{hash}, error: #{error.inspect}")
      errors[:base] << error.message
      false
    end

    def changed_mappings
      mappings.select { |attr, sf_field| changed.include? attr.to_s}
    end

    def read_value field
      case sf_field_type field
      when :multi_picklist
        attribute(field.to_s).reject(&:empty?).join(';')
      else
        attribute(field.to_s)
      end
    end

    def sf_field_type field
      self.class.attributes[field][:sf_tpye]
    end

    def sfdc_client
      self.class.sfdc_client
    end
  end
end
