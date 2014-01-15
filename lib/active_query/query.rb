module ActiveQuery
  class Query
    attr_accessor :table, :fields, :conditions, :size, :table_id

    def initialize
      self.conditions = []
      self.table_id = 'Id'
    end

    def all
      self
    end

    def to_s
      query = <<-SOQL.gsub(/\s+/, " ").strip  
        SELECT
          #{ fields.join(', ') }
        FROM
          #{ table }
        #{ build_where }
        #{ build_limit }
      SOQL
      query
    end

    def where condition
      self.conditions << condition
      self
    end

    def limit size
      self.size = size
      self
    end

    def find id
      where "#{ table_id } = '#{ id }'"
      limit 1
      self
    end

    protected
      def build_where
        unless conditions.empty?
          "WHERE #{ conditions.join(' AND ') }"
        end
      end

      def build_limit
        "LIMIT #{ size }" if size
      end
  end
end