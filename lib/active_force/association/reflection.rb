module ActiveForce
  module Association
    module Reflection
      class << self
        def included(base)
          base.class_eval do
            class_attribute :reflections
            self.reflections = {}
          end
          base.extend ClassMethods
        end

        def create(macro, relation_name, sobject, options={})
          klass = case macro
          when :belongs_to; BelongsToReflection
          when :has_many; HasManyReflection
          else
            raise ArgumentError, "Unknown macro #{macro}"
          end
          reflection = klass.new(relation_name, sobject, options)
          reflection.define_accessors
          reflection
        end

        def add_reflection(sobject, name, reflection)
          sobject.reflections = sobject.reflections.merge(name => reflection)
        end
      end

      module ClassMethods
        def reflect_on_association(relation_name)
          reflections[relation_name]
        end
      end

      class AbstractReflection
        attr_reader :relation_name, :sobject, :options

        def initialize(relation_name, sobject, options={})
          @relation_name = relation_name
          @sobject = sobject
          @options = options
        end

        def relation_model
          options[:model] || relation_name.to_s.singularize.camelcase.constantize
        end

        def foreign_key
          options[:foreign_key] || default_foreign_key
        end

        def salesforce_relationship_name
          "#{applicable_model_name(relation_model)}__r"
        end

        private

        def applicable_model_name(model)
          model.custom_table_name? ? model.name : model.table_name
        end

        def infer_foreign_key_from_model(model)
          name = applicable_model_name model
          "#{name.downcase}_id".to_sym
        end
      end

      class BelongsToReflection < AbstractReflection
        def define_accessors
          _method = relation_name
          reflection = self
          sobject.send :define_method, _method do
            association_cache.fetch(_method) do
              association_cache[_method] = reflection.relation_model.find(send reflection.foreign_key)
            end
          end

          sobject.send :define_method, "#{_method}=" do |other|
            send "#{ reflection.foreign_key }=", other.id
            association_cache[_method] = other
          end
        end

        private

        def default_foreign_key
          infer_foreign_key_from_model relation_model
        end
      end

      class HasManyReflection < AbstractReflection
        def define_accessors
          _method = relation_name
          reflection = self
          sobject.send :define_method, _method do
            association_cache.fetch _method do
              query = reflection.relation_model.query
              query.options reflection.options
              association_cache[_method] = query.where reflection.foreign_key => self.id
            end
          end
        end

        private

        def default_foreign_key
          infer_foreign_key_from_model sobject
        end
      end
    end
  end
end
