module ActiveForce
  module Association

    class BelongsToAssociation < Association

      def foreign_key
        options[:foreign_key] || "#{ @relation_name }_id".to_sym
      end

      private

      def define_relation_method
        association = self
        @parent.send :define_method, @relation_name do
          association.relation_model.find(self.send association.foreign_key)
        end
      end
    end

  end
end
