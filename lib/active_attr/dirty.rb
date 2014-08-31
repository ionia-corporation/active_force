require 'active_support'
require 'active_model/dirty'
require 'active_attr'

module ActiveAttr
  module Dirty
    extend ActiveSupport::Concern
    include ActiveModel::Dirty

    module ClassMethods
      def attribute!(name, options={})
        super(name, options)
        define_method("#{name}=") do |value|
          send("#{name}_will_change!") unless value == read_attribute(name)
          super(value)
        end
      end
    end

  end
end
