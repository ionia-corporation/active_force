require 'active_force/query'

module ActiveForce
  module Association
    module ClassMethods
      def has_many relation_name, options = {}
        define_method "#{ relation_name }_query".to_sym do
          table            = relation_name.to_s.singularize.capitalize
          association_name = options[:table] || "#{ table }__c"
          foreing_key      = options[:foreing_key] || table_name
          query = ActiveForce::Query.new(association_name)
          query.fields table.constantize.fields
          query.where("#{ foreing_key } = '#{ id }'")
          query
        end
      end
    end
  end
end