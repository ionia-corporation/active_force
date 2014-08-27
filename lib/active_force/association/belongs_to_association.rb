module ActiveForce
  module Association

    class BelongsToAssociation < Association

      private

      def default_foreign_key
        infer_foreign_key_from_model relation_model
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
