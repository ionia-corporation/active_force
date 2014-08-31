module ActiveForce
  class Attribute

    attr_accessor :name, :from, :as, :value, :client, :table_name

    def initialize name, options = {}
      self.name = name
      self.from      = options[:from] || default_api_name
      self.as        = options[:as]   || :string
    end

    def picklist
      client.picklist_values(table_name, from).map do |value|
        [value[:label], value[:value]]
      end
    end

    def value_for_hash
      case as
      when :multi_picklist
        value.reject(&:empty?).join(';')
      else
        value.to_s
      end
    end

    private

    ###
    # Transforms +attribute+ to the conventional Salesforce API name.
    #
    def default_api_name
      name.to_s.split('_').map(&:capitalize).join('_') << '__c'
    end
  end
end
