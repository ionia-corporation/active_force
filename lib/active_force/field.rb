module ActiveForce
  class Field

    attr_accessor :local_name, :sfdc_name, :as

    def initialize name, options = {}
      self.local_name = name
      self.sfdc_name  = options[:sfdc_name] || options[:from] || default_api_name
      self.as         = options[:as]        || :string
    end

    def value_for_hash value
      case as
      when :multi_picklist
        value.reject(&:empty?).join(';')
      else
        value
      end
    end

    private

    ###
    # Transforms +attribute+ to the conventional Salesforce API name.
    #
    def default_api_name
      local_name.to_s.split('_').map(&:capitalize).join('_') << '__c'
    end
  end
end
