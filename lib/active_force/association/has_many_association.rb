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
        association_name = self.association_name
        relation_model = self.relation_model
        foreign_key = self.foreign_key
        options = @options
        @parent.send :define_method, query_method_name do
          query = Query.new association_name
          query.fields relation_model.fields
          query.where options[:where] if options[:where]
          query.order options[:order] if options[:order]
          query.limit options[:limit] if options[:limit]
          query.where "#{ foreign_key } = '#{ self.id }'"
          query
        end
      end

      def define_relation_method
        relation_model = self.relation_model
        query_method_name = self.query_method_name
        @parent.send :define_method, @relation_name do
          relation_model.send_query send(query_method_name)
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
