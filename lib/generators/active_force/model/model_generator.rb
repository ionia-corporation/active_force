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
      begin
        @columns ||= ActiveForce::SObject.sfdc_client.describe(@table_name).fields.map do |field|
          field.name
        end
      rescue Faraday::Error::ResourceNotFound
        puts "The specified table name is not found. Be sure to append __c if it's custom"
      end
    end

    def table_exists?
      !! sfdc_columns
    end

    def column_to_field column
      sf_name = sf_name.underscore
      sf_name = sf_name[0..-4] if sf_name.include? "__c"
      sf_name.to_sym
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
