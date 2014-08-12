require 'active_force/query'
require 'active_force/finders'

module ActiveForce
  class ActiveQuery < Query
    include ActiveForce::Finders

    attr_reader :sobject

    delegate :sfdc_client, :build, :table_name, :mappings, to: :sobject

    def initialize sobject
      @sobject = sobject
      super table_name
      fields sobject.fields
    end

    def to_a
      sfdc_client.query(to_s).to_a.map do |mash|
        build mash
      end
    end

    def count
      super
      sfdc_client.query.first.expr0
    end

    def all
      to_a
    end

    def limit limit
      super
      limit == 1 ? to_a.first : self
    end

    def where conditions
      return super unless conditions.is_a? Hash
      conditions.each do |key, value|
        super "#{ mappings[key] } = #{ enclose_value value }"
      end
      self
    end

    private

    def enclose_value value
      if value.is_a? String
        "'#{value}'"
      else
        value.to_s
      end
    end
  end
end
