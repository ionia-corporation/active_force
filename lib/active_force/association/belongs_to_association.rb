module ActiveForce
  module Association
    class BelongsToAssociation < Association

      private

      def default_foreign_key
        infer_foreign_key_from_model relation_model
      end

      def define_relation_method
        association = self
        relation_cache = relation_instance_name
        @parent.send :define_method, @relation_name do
          return instance_variable_get(relation_cache) if instance_variable_defined? relation_cache
          foreign_key_value = send association.foreign_key
          association_object = association.relation_model.find(foreign_key_value)
          instance_variable_set relation_cache, association_object
        end
      end
    end

  end
end
