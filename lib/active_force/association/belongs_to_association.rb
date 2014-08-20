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
          association.relation_model.find(send association.foreign_key)
        end
      end
    end

  end
end
