require 'active_force/query'

module ActiveForce
  class ActiveQuery < Query

    attr_reader :sobject

    delegate :sfdc_client, :build, :table_name, :mappings, to: :sobject

    def initialize sobject
      @sobject = sobject
      super table_name
      fields sobject.fields
    end

    def to_a
      result.to_a.map do |mash|
        build mash
      end
    end

    def count
      super
      sfdc_client.query(to_s).first.expr0
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

    def find_by conditions
      where(conditions).limit 1
    end

    private

    def enclose_value value
      if value.is_a? String
        "'#{value}'"
      else
        value.to_s
      end
    end

    def result
      sfdc_client.query(self.to_s)
    end
  end
end
