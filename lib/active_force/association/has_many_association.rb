module ActiveForce
  module Association
    class HasManyAssociation < Association
      private

      def default_foreign_key
        infer_foreign_key_from_model @parent
      end

      def define_relation_method
        association = self
        _method = @relation_name
        @parent.send :define_method, _method do
          association_cache.fetch _method do
            query = association.relation_model.query
            query.options association.options
            association_cache[_method] = query.where association.foreign_key => self.id
          end
        end

        @parent.send :define_method, "#{_method}=" do |associated|
          association_cache[_method] = associated
        end
      end
    end
  end
end
