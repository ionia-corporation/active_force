require 'active_force/association/association'
require 'active_force/association/eager_load_projection_builder'
require 'active_force/association/relation_model_builder'
require 'active_force/association/has_many_association'
require 'active_force/association/belongs_to_association'

module ActiveForce
  module Association
    def associations
      @associations ||= {}
    end

    # i.e name = 'Quota__r'
    def find_association name
      associations.values.detect do |association|
        association.represents_sfdc_table? name
      end
    end

    def has_many relation_name, options = {}
      associations[relation_name] = HasManyAssociation.new(self, relation_name, options)
    end

    def belongs_to relation_name, options = {}
      associations[relation_name] = BelongsToAssociation.new(self, relation_name, options)
    end
  end
end
