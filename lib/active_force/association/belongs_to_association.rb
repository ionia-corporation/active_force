module ActiveForce
  module Association

    class BelongsToAssociation < Association

      private

      def default_foreign_key
        "#{ relation_model.name.downcase }_id".to_sym
      end

      def define_relation_method
        association = self
        @parent.send :define_method, @relation_name do
          relation_cache = association.relation_instance_name
          return instance_variable_get(relation_cache) if instance_variable_defined? relation_cache
          foreign_key_value = send association.foreign_key
          association_object = association.relation_model.find(foreign_key_value)
          instance_variable_set association.relation_instance_name, association_object
        end
      end
    end

  end
end
