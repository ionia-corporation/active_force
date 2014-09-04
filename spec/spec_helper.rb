require "codeclimate-test-reporter"
CodeClimate::TestReporter.start

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'restforce'
require 'active_force'
Dir["./spec/support/**/*"].sort.each { |f| require f }
require 'pry'

ActiveSupport::Inflector.inflections do |inflect|
  inflect.plural 'quota', 'quotas'
  inflect.singular 'quota', 'quota'
  inflect.plural 'territory', 'territories'
  inflect.singular 'territory', 'territory'
end

class Territory < ActiveForce::SObject
  field :quota_id, from: "Quota__c"
  belongs_to :quota
end
class Quota < ActiveForce::SObject
  field :id, from: 'Bar_Id__c'
  has_many :territories
end

