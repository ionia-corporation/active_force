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

      def foreign_key
        @options[:foreign_key] || default_foreign_key
      end

      private

      def build
        define_relation_method
      end

      def infer_foreign_key_from_model(model)
        name = model.custom_table_name? ? model.name : model.table_name
        "#{name.downcase}_id".to_sym
      end
    end

  end
end
