module ActiveForce
  module Association
    class HasManyAssociation < Association
      ###
      # Use ActiveForce::Query to build a subquery for the SFDC
      # relationship name. Per SFDC convention, the name needs
      # to be pluralized
      def eager_load_projections
        match = sfdc_association_field.match /__r\z/
        # pluralize the table name, and append '__r' if it was there to begin with
        relationship_name = sfdc_association_field.sub(match.to_s, '').pluralize + match.to_s
        query = Query.new relationship_name
        query.fields relation_model.fields
        ["(#{query.to_s})"]
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
