module ActiveForce
  class Query
    attr_reader :table

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
      <<-SOQL.gsub(/\s+/, " ").strip
        SELECT
          #{ build_select }
        FROM
          #{ @table }
        #{ build_where }
        #{ build_order }
        #{ build_limit }
        #{ build_offset }
      SOQL
    end

    def where condition
      @conditions << condition if condition
      self
    end

    def order order
      @order = order if order
      self
    end

    def limit size
      @size = size if size
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

    def last
      order("Id DESC").limit(1)
    end

    def join object_query
      fields ["(#{ object_query.to_s })"]
      self
    end

    def count
      @query_fields = ["count(Id)"]
      self
    end

    def options args
      where args[:where]
      limit args[:limit]
      order args[:order]
    end

    protected
      def build_select
        @query_fields.uniq.join(', ')
      end

      def build_where
        "WHERE #{ @conditions.join(' AND ') }" unless @conditions.empty?
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
