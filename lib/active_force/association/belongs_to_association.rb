module ActiveForce
  module Association

    class BelongsToAssociation < Association

      private

      def default_foreign_key
        name = if relation_model.custom_table_name?
          relation_model.name
        else
          relation_model.table_name
        end
        "#{name.downcase}_id".to_sym
      end

      def define_relation_method
        association = self
        @parent.send :define_method, @relation_name do
          association.relation_model.find(send association.foreign_key)
        end
      end
    end

  end
end
