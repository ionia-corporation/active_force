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

    def where args=nil, *rest
      return self if args.nil?
      super build_condition args, rest
      self
    end

    def find_by conditions
      where(conditions).limit 1
    end

    def includes(relation)
      reflection = sobject.reflect_on_association relation
      fields build_eager_load_projections reflection
      self
    end

    private

    def build_eager_load_projections(reflection)
      related_model_fields = reflection.relation_model.fields
      related_model_fields.map do |field|
        reflection.salesforce_relationship_name + '.' + field
      end
    end

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
        "#{mappings[key]} = #{enclose_value value}"
      end
    end

    def enclose_value value
      case value
      when String
        "'#{value}'"
      when NilClass
        'NULL'
      else
        value.to_s
      end
    end

    def result
      sfdc_client.query(self.to_s)
    end
  end
end
