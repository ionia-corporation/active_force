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
        @value = value.respond_to?(:to_hash) ? value.to_hash : value
      end

      def build_relation_model
        klass = resolve_class
        klass.new(@association, @value).call
      end

      private

      def resolve_class
        ActiveForce::Association.const_get "BuildFrom#{@value.class.name}"
      rescue NameError
        raise "Don't know how to build relation from #{@value.class.name}"
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
