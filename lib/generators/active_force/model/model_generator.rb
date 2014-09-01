module ActiveForce
  class ModelGenerator < Rails::Generators::NamedBase
    desc 'This generator loads the table fields from SFDC and generates the fields for the SObject with a more ruby names'

    source_root File.expand_path('../templates', __FILE__)

    def create_model_file
      @table_name = file_name.capitalize
      @class_name = @table_name.gsub '__c', ''
      template "model.rb.erb", "app/models/#{@class_name.downcase}.rb" if table_exists?
    end

    protected

    Attribute = Struct.new :field, :column

    def attributes 
      @attributes ||= sfdc_columns.map do |column|
        Attribute.new column_to_field(column), column
      end
    end

    def sfdc_columns
      @columns ||= ActiveForce::SObject.sfdc_client.describe(@table_name).fields.map do |field|
        field.name
      end
    end

    def table_exists?
      !! sfdc_columns
      rescue Faraday::Error::ResourceNotFound
        puts "The specified table name is not found. Be sure to append __c if it's custom"
    end

    def column_to_field column
      column.underscore.gsub("__c", "").to_sym
    end

    def attribute_line attribute
      "field :#{ attribute.field },#{ space_justify attribute.field }  from: '#{ attribute.column }'"
    end

    def space_justify field_name
      longest_field = attributes.map { |attr| attr.field.length } .max
      justify_count = longest_field - field_name.length
      " " * justify_count
    end


    class String
      def underscore
        self.gsub(/::/, '/').
        gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
        gsub(/([a-z\d])([A-Z])/,'\1_\2').
        tr("-", "_").
        downcase
      end
    end

  end
end
