require 'active_force/query'
require 'active_force/association/has_many_association'

module ActiveForce
  module Association
    module ClassMethods

      def has_many relation_name, options = {}
        HasManyAssociation.new self, relation_name, options
      end

      def relation_model sym
        sym.to_s.singularize.camelcase.constantize
      end

      def default_foreign_key relation_model, model
        relation_model.mappings["#{model.downcase}_id".to_sym]
      end

      def belongs_to relation_name, options = {}
        model = options[:model] || relation_model(relation_name)
        foreign_key      = options[:foreign_key] || "#{ relation_name }_id".to_sym
        define_method "#{ relation_name }" do
          model.find(self.send foreign_key)
        end
      end

    end

    def self.included mod
      mod.extend ClassMethods
    end

  end
end
