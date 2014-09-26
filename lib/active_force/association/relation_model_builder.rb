module ActiveForce
  module Association
    class RelationModelBuilder
      class << self
        def build(association, value)
          new(association, value).build_relation_model
        end
      end

      def initialize(association, value)
        @association = association
        @value = value
      end

      def build_relation_model
        klass = ActiveForce::Association.const_get "BuildFrom#{@value.class.name}"
        klass.new(@association, @value).call
      end
    end

    class AbstractBuildFrom
      attr_reader :association, :value

      def initialize(association, value)
        @association = association
        @value = value
      end

      def call
        raise "Must implement #{self.class.name}#call"
      end
    end

    class BuildFromHash < AbstractBuildFrom
      def call
        association.build value
      end
    end

    class BuildFromArray < AbstractBuildFrom
      def call
        value.map { |mash| association.build mash }
      end
    end

    class BuildFromNilClass < AbstractBuildFrom
      def call
        association.is_a?(BelongsToAssociation) ? nil : []
      end
    end
  end
end
