module ActiveForce
  module Attributable

    extend ActiveSupport::Concern

    module ClassMethods

      def define_attribute_reader(name, options = Hash.new)
        wrapper = Module.new do
          define_method name do
            return instance_variable_get("@#{name}")
          end
        end
        include wrapper
      end

      def define_attribute_writer(name, options = Hash.new)
        wrapper = Module.new do
          define_method "#{name}=" do |value|
            converted_value = ActiveModel::Type.lookup(options[:as] || :string).cast(value)
            send(:"#{name}_will_change!") unless instance_variable_get("@#{name}") == converted_value
            instance_variable_set("@#{name}", converted_value)
          end
        end
        include wrapper
      end

    end
  end
end
