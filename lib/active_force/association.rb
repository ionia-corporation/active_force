require 'active_force/query'

module ActiveForce
  module Association
    module ClassMethods
      def has_many relation_name, options = {}
        model = options[:model] || relation_model(relation_name)
        association_name = options[:table] || model.table_name || "#{ model }__c"
        foreing_key      = options[:foreing_key] || default_foreing_key(model, self.name) || table_name

        define_method "#{ relation_name }_query" do
          query = ActiveForce::Query.new(association_name)
          query.fields model.fields
          query.where(options[:where]) if options[:where]
          query.where("#{ foreing_key } = '#{ id }'")
          query
        end
      end

      def relation_model sym
        sym.to_s.singularize.camelcase.constantize
      end

      def default_foreing_key relation_model, model
        relation_model.mappings["#{model.downcase}_id".to_sym]
      end
    end
  end
end