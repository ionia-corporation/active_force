module ActiveForce
  module Association
    class HasManyAssociation

      def initialize parent, relation_name, options
        @parent = parent
        @relation_name = relation_name
        @options = options
        define_query_method
        define_relation_method
      end

      def define_query_method
        association = self
        options = @options
        @parent.send :define_method, query_method_name do
          query = association.relation_model.query
          query.options options
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

      def association_name
        @options[:table] || relation_model.table_name || "#{ relation_model }__c"
      end

      def foreign_key
        @options[:foreign_key] || default_sfdc_foreign_key || @parent.table_name
      end

      def relation_model
        @options[:model] || @relation_name.to_s.singularize.camelcase.constantize
      end

      def default_sfdc_foreign_key
        relation_model.mappings["#{ @parent.name.downcase }_id".to_sym]
      end

    end
  end
end
