require 'active_force/query'
require 'forwardable'

module ActiveForce
  class PreparedStatementInvalid < ArgumentError; end
  class ActiveQuery < Query
    extend Forwardable

    attr_reader :sobject

    def_delegators :sobject, :sfdc_client, :build, :table_name, :mappings
    def_delegators :to_a, :each, :map, :inspect

    def initialize sobject
      @sobject = sobject
      super table_name
      fields sobject.fields
    end

    def to_a
      @records ||= result.to_a.map { |mash| build mash }
    end

    alias_method :all, :to_a

    def count
      super
      sfdc_client.query(to_s).first.expr0
    end

    def limit limit
      super
      limit == 1 ? to_a.first : self
    end

    def select *fields
      fields.map! { |field| mappings[field] }
      super *fields
    end

    def find_by conditions
      where(conditions).limit 1
    end

    def includes(*relations)
      relations.each do |relation|
        association = sobject.associations[relation]
        fields Association::EagerLoadProjectionBuilder.build association
      end
      self
    end

    def none
      @records = []
      where(id: '1'*18).where(id: '0'*18)
    end

    private

    def result
      sfdc_client.query(self.to_s)
    end
  end
end
