require "codeclimate-test-reporter"
CodeClimate::TestReporter.start

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'restforce'
require 'active_force'
Dir["./spec/support/**/*"].sort.each { |f| require f }
require 'pry'

ActiveSupport::Inflector.inflections do |inflect|
  inflect.plural 'quota', 'quotas'
  inflect.plural 'Quota', 'Quotas'
  inflect.singular 'quota', 'quota'
  inflect.singular 'Quota', 'Quota'
end

class Territory < ActiveForce::SObject
  field :quota_id, from: "Quota__c"
  belongs_to :quota
end
class PrezClub < ActiveForce::SObject
  field :quota_id, from: 'QuotaId'
  belongs_to :quota
end
class Quota < ActiveForce::SObject
  field :id, from: 'Bar_Id__c'
  has_many :prez_clubs
  has_many :territories
end
class Opportunity < ActiveForce::SObject
  field :account_id, from: 'AccountId'
  belongs_to :account
end
class Account < ActiveForce::SObject
  field :owner_id, from: 'OwnerId'
  has_many :opportunities
  belongs_to :owner
end
class Owner < ActiveForce::SObject
  has_many :accounts
end


module Salesforce
  class PrezClub < ActiveForce::SObject
    field :quota_id, from: 'QuotaId'
  end
  class Quota < ActiveForce::SObject
    has_many :prez_clubs, model: PrezClub
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

