module ActiveForce
  module Association
    class EagerLoadProjectionBuilder
      class << self
        def build(association)
          new(association).projections
        end
      end

      attr_reader :association

      def initialize(association)
        @association = association
      end

      def projections
        klass = association.class.name.split('::').last
        builder_class = ActiveForce::Association.const_get "#{klass}ProjectionBuilder"
        builder_class.new(association).projections
      rescue NameError
        raise "Don't know how to build projections for #{klass}"
      end
    end

    class AbstractProjectionBuilder
      attr_reader :association

      def initialize(association)
        @association = association
      end

      def projections
        raise "Must define #{self.class.name}#projections"
      end
    end

    class HasManyAssociationProjectionBuilder < AbstractProjectionBuilder
      ###
      # Use ActiveForce::Query to build a subquery for the SFDC
      # relationship name. Per SFDC convention, the name needs
      # to be pluralized
      def projections
        match = association.sfdc_association_field.match /__r\z/
        # pluralize the table name, and append '__r' if it was there to begin with
        relationship_name = association.sfdc_association_field.sub(match.to_s, '').pluralize + match.to_s
        query = Query.new relationship_name
        query.fields association.relation_model.fields
        ["(#{query.to_s})"]
      end
    end

    class BelongsToAssociationProjectionBuilder < AbstractProjectionBuilder
      def projections
        association.relation_model.fields.map do |field|
          "#{ association.sfdc_association_field }.#{ field }"
        end
      end
    end
  end
end
