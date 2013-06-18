class ActiveForce::ActiveForceModelGenerator < Rails::Generators::NamedBase

  Attribute = Struct.new(:local_name, :remote_name)

  source_root File.expand_path('../templates', __FILE__)
  argument :attributes, type: :array, default: [],
    banner: "field[:sales_force_name] field[:sales_force_name]"

  def create_model_file
    template "model.rb.erb", "app/models/#{file_name}.rb"
  end

  protected

  def parse_attributes! #:nodoc:
    self.attributes = (attributes || []).map do |attr|
      name, sales_force_name = attr.split ':', 2
      remote_name = sales_force_name.presence || name
      Attribute.new name, remote_name
    end
  end
end
