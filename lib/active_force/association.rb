require 'active_force/query'
require 'active_force/association/association'
require 'active_force/association/has_many_association'
require 'active_force/association/belongs_to_association'

module ActiveForce
  module Association
    module ClassMethods

      def has_many relation_name, options = {}
        HasManyAssociation.new(self, relation_name, options)
      end

      def belongs_to relation_name, options = {}
        BelongsToAssociation.new(self, relation_name, options)
      end

    end

    def self.included mod
      mod.extend ClassMethods
    end

  end
end
