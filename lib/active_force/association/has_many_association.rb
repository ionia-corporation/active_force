module ActiveForce
  module Association
    class HasManyAssociation < Association

      private

      def default_foreign_key
        "#{ @parent.name.downcase }_id".to_sym
      end

      def define_relation_method
        association = self
        @parent.send :define_method, @relation_name do
          query = association.relation_model.query
          query.options association.options
          query.where association.foreign_key => self.id
        end
      end
    end
  end
end
