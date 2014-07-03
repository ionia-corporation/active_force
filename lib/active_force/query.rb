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
      @query_fields = @query_fields + fields_collection.to_a
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
        #{ build_order }
        #{ build_limit }
        #{ build_offset }
      SOQL
      query
    end

    def where condition
      @conditions << condition
      self
    end

    def order order
      @order = order
      self
    end

    def limit size
      @size = size
      self
    end

    def limit_value
      @size
    end

    def offset offset
      @offset = offset
      self
    end

    def offset_value
      @offset
    end

    def find id
      where "#{ @table_id } = '#{ id }'"
      limit 1
    end

    def first
      limit 1
    end

    def join object_query
      fields ["(#{ object_query.to_s })"]
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

      def build_order
        "ORDER BY #{ @order }" if @order
      end

      def build_offset
        "OFFSET #{ @offset }" if @offset
      end
  end
end