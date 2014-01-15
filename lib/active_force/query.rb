module ActiveForce
  class Query
    attr_reader :table

    attr_accessor :table_id

    def initialize table
      @table = table
      @conditions = []
      @table_id = 'Id'
      @query_fields = [@table_id]
    end

    def fields fields_collection = []
      @query_fields = @query_fields + fields_collection
    end

    def all
      self
    end

    def to_s
      query = <<-SOQL.gsub(/\s+/, " ").strip  
        SELECT
          #{ @query_fields.uniq.join(', ') }
        FROM
          #{ @table }
        #{ build_where }
        #{ build_limit }
      SOQL
      query
    end

    def where condition
      @conditions << condition
      self
    end

    def limit size
      @size = size
      self
    end

    def find id
      where "#{ @table_id } = '#{ id }'"
      limit 1
      self
    end

    protected
      def build_where
        unless @conditions.empty?
          "WHERE #{ @conditions.join(' AND ') }"
        end
      end

      def build_limit
        "LIMIT #{ @size }" if @size
      end
  end
end