module ActiveForce
  module Association
    class HasManyAssociation < Association

      def foreign_key
        @options[:foreign_key] || default_sfdc_foreign_key || @parent.table_name
      end

      private

      def build
        super
        define_query_method
      end

      def define_query_method
        association = self
        @parent.send :define_method, query_method_name do
          query = association.relation_model.query
          query.options association.options
          query.where "#{ association.foreign_key } = '#{ self.id }'"
        end
      end

      def define_relation_method
        association = self
        @parent.send :define_method, @relation_name do
          association.relation_model.send_query send(association.query_method_name)
        end
      end

      def query_method_name
        "#{ @relation_name }_query"
      end
    end
  end
end
