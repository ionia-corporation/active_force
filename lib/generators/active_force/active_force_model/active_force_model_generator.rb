module ActiveForce
  class ActiveForceModelGenerator < Rails::Generators::NamedBase

    source_root File.expand_path('../templates', __FILE__)

    def create_model_file

      sf_field_names = list_field_names file_name.capitalize
      @attributes = create_attributes sf_field_names

      template "model.rb.erb", "app/models/#{file_name}.rb"
    end

    protected

    Attribute = Struct.new(:local_name, :remote_name)

    def create_attributes sf_field_names
      sf_field_names.map do |field|
        Attribute.new( sf_name_to_symbol(field) ,field)
      end
    end

    def list_field_names table_name
      Client.describe(table_name).fields.map do |field|
        field.name
      end
    end

    def sf_name_to_symbol sf_name
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