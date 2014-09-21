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

module Salesforce
  class Quota < ActiveForce::SObject
  end
  class Widget < ActiveForce::SObject
    self.table_name = 'Tegdiw__c'
  end
  class Territory < ActiveForce::SObject
    field :quota_id, from: "QuotaId"
    field :widget_id, from: 'WidgetId'
    belongs_to :quota, model: Salesforce::Quota, foreign_key: :quota_id
    belongs_to :widget, model: Salesforce::Widget, foreign_key: :widget_id
  end
end

