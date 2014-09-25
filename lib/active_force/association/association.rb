module ActiveForce
  module Association
    class Association

      attr_accessor :options, :relation_name

      def initialize parent, relation_name, options
        @parent        = parent
        @relation_name = relation_name
        @options       = options
        build
      end

      def relation_model
        options[:model] || relation_name.to_s.singularize.camelcase.constantize
      end

      def foreign_key
        options[:foreign_key] || default_foreign_key
      end

      def relationship_name
        options[:relationship_name] || relation_model.table_name
      end

      ###
      # Does this association's relation_model represent
      # +sfdc_table_name+? Examples of +sfdc_table_name+
      # could be 'Quota__r' or 'Account'.
      def represents_sfdc_table?(sfdc_table_name)
        name = sfdc_table_name.sub(/__r\z/, '').singularize
        relationship_name.sub(/__c\z/, '') == name
      end

      def sfdc_association_field
        relationship_name.gsub /__c\z/, '__r'
      end

      private

      def build
        define_relation_method
      end

      def infer_foreign_key_from_model(model)
        name = model.custom_table? ? model.name : model.table_name
        "#{name.downcase}_id".to_sym
      end
    end

  end
end
