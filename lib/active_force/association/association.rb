module ActiveForce
  module Association
    class Association

      attr_accessor :options

      def initialize parent, relation_name, options
        @parent = parent
        @relation_name = relation_name
        @options = options
        build
      end

      def relation_model
        @options[:model] || @relation_name.to_s.singularize.camelcase.constantize
      end

      private

      def build
        define_relation_method
      end

      def default_sfdc_foreign_key
        relation_model.mappings["#{ @parent.name.downcase }_id".to_sym]
      end
    end

  end
end
