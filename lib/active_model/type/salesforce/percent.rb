require 'active_model'

module ActiveModel
  module Type
    module Salesforce
      class Percent < ActiveModel::Type::Value

        def type
          :percent
        end

        private

        def cast_value(value)
          value.to_f
        end
      end
    end
  end
end

ActiveModel::Type.register(:percent, ActiveModel::Type::Salesforce::Percent)
