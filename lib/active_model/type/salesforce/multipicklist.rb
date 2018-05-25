require 'active_model'

module ActiveModel
  module Type
    module Salesforce
      class Mulitpicklist < ActiveModel::Type::Value

        def type
          :multipicklist
        end

        private

        def cast_value(value)
          (value || "").split(";")
        end
      end
    end
  end
end

ActiveModel::Type.register(:multipicklist, ActiveModel::Type::Salesforce::Mulitpicklist)
