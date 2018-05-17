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
            # if cast_type.is_a?(Symbol)
            #   cast_type = ActiveModel::Type.lookup(cast_type, **options.except(*SERVICE_ATTRIBUTES))
            # end
            # deserialized_value = cast_type.cast(val)
            send(:"#{name}_will_change!") unless instance_variable_get("@#{name}") == value
            instance_variable_set("@#{name}", value)
          end
        end
        include wrapper
      end

    end
  end
end
