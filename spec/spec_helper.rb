require "codeclimate-test-reporter"
CodeClimate::TestReporter.start

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'restforce'
require 'active_force'
Dir["./spec/support/**/*"].sort.each { |f| require f }
require 'pry'

class Territory < ActiveForce::SObject; end
class Quota < ActiveForce::SObject
  field :id, from: 'Bar_Id__c'
end

ActiveSupport::Inflector.inflections do |inflect|
  inflect.plural 'quota', 'quotas'
  inflect.singular 'quota', 'quota'
end
