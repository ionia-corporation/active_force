require 'active_force/association/reflection'

module ActiveForce
  module Association
    extend ActiveSupport::Concern

    module ClassMethods
      def has_many relation_name, options = {}
        reflection = Reflection.create :has_many, relation_name, self, options
        Reflection.add_reflection self, relation_name, reflection
      end

      def belongs_to relation_name, options = {}
        reflection = Reflection.create :belongs_to, relation_name, self, options
        Reflection.add_reflection self, relation_name, reflection
      end
    end
  end
end
