require 'active_force/version'
require 'active_force/sobject'
require 'active_force/query'

module ActiveForce

  class << self
    attr_accessor :sfdc_client
  end

  self.sfdc_client = Restforce.new

end
