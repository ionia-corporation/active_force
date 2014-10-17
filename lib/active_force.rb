require 'active_force/version'
require 'active_force/sobject'
require 'active_force/query'
require 'active_force/configuration'

module ActiveForce
  extend self

  def configure
    yield configuration
  end

  def configuration
    @configuration ||= Configuration.new
  end
end
