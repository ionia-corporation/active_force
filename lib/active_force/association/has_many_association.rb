module ActiveForce
  module Association
    class HasManyAssociation < Association

      def apply_scope query
        if scope = self.options[:scoped_as]
          if scope.arity > 0
            query.instance_exec self, &scope
          else
            query.instance_exec &scope
          end
        end
        query
      end

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
            apply_scope query
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
