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

      def relation_instance_name
        "@cached_#{ @relation_name }"
      end

      private

      def build
        define_relation_method
      end

    end

  end
end
