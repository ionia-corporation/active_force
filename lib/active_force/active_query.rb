require 'active_force/query'

module ActiveForce
  class ActiveQuery < Query
    attr_reader :sobject

    delegate :sfdc_client, :build, :table_name, to: :sobject

    def initialize sobject
      @sobject = sobject
      super table_name
    end

    def to_a
      sfdc_client.query(to_s).to_a.map do |mash|
        build mash
      end
    end

  end
end
