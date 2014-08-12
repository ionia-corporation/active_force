module ActiveForce
  module Association
    class HasManyAssociation < Association

      def foreign_key
        @options[:foreign_key] || default_sfdc_foreign_key || @parent.table_name
      end

      private

      def define_relation_method
        association = self
        @parent.send :define_method, @relation_name do
          query = association.relation_model.query
          query.options association.options
          query.where "#{ association.foreign_key } = '#{ self.id }'"
        end
      end
    end
  end
end
