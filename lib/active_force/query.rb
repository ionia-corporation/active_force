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
      @query_fields += fields_collection.to_a
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

    def select *columns
      @query_fields = columns
      self
    end

    def where args=nil, *rest
      return self if args.nil?
      condition = build_condition args, rest
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

    protected
      def build_select
        @query_fields.compact.uniq.join(', ')
      end

      def build_where
        "WHERE (#{ @conditions.join(') AND (') })" unless @conditions.empty?
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

    private

    def build_condition(args, other=[])
      case args
      when String, Array
        build_condition_from_array other.empty? ? args : ([args] + other)
      when Hash
        build_conditions_from_hash args
      else
        args
      end
    end

    def build_condition_from_array(ary)
      statement, *bind_parameters = ary
      return statement if bind_parameters.empty?
      if bind_parameters.first.is_a? Hash
        replace_named_bind_parameters statement, bind_parameters.first
      else
        replace_bind_parameters statement, bind_parameters
      end
    end

    def replace_named_bind_parameters(statement, bind_parameters)
      statement.gsub(/(:?):([a-zA-Z]\w*)/) do
        key = $2.to_sym
        if bind_parameters.has_key? key
          enclose_value bind_parameters[key]
        else
          raise PreparedStatementInvalid, "missing value for :#{key} in #{statement}"
        end
      end
    end

    def replace_bind_parameters(statement, values)
      raise_if_bind_arity_mismatch statement.count('?'), values.size
      bound = values.dup
      statement.gsub('?') do
        enclose_value bound.shift
      end
    end

    def raise_if_bind_arity_mismatch(expected_var_count, actual_var_count)
      if expected_var_count != actual_var_count
        raise PreparedStatementInvalid, "wrong number of bind variables (#{actual_var_count} for #{expected_var_count})"
      end
    end

    def build_conditions_from_hash(hash)
      hash.map do |key, value|
        applicable_predicate mappings[key], value
      end
    end

    def applicable_predicate(attribute, value)
      if value.is_a? Array
        in_predicate attribute, value
      else
        eq_predicate attribute, value
      end
    end

    def in_predicate(attribute, values)
      escaped_values = values.map &method(:enclose_value)
      "#{attribute} IN (#{escaped_values.join(',')})"
    end

    def eq_predicate(attribute, value)
      "#{attribute} = #{enclose_value value}"
    end

    def enclose_value value
      case value
      when String
        "'#{quote_string(value)}'"
      when NilClass
        'NULL'
      else
        value.to_s
      end
    end

    def quote_string(s)
      # From activerecord/lib/active_record/connection_adapters/abstract/quoting.rb, version 4.1.5, line 82
      s.gsub(/\\/, '\&\&').gsub(/'/, "''")
    end
  end
end
