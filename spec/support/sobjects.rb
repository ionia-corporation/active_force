
class Comment < ActiveForce::SObject
  self.table_name = "Comment__c"
  field :post_id, from: "PostId"
  field :poster_id, from: 'PosterId__c'
  field :fancy_post_id, from: 'FancyPostId'
  belongs_to :post
end
class Post < ActiveForce::SObject
  self.table_name = "Post__c"
  has_many :comments
  has_many :impossible_comments, { where: '1 = 0', model: Comment }
  has_many :ugly_comments, { model: Comment }
  has_many :poster_comments, { foreign_key: :poster_id, model: Comment }
end
class Territory < ActiveForce::SObject
  field :quota_id, from: "Quota__c"
  field :name, from: 'Name'
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
class Custom < ActiveForce::SObject; end
class EnforcedTableName < ActiveForce::SObject
  self.table_name = 'Forced__c'
end

module Foo
  class Bar < ActiveForce::SObject; end
  class Opportunity < ActiveForce::SObject
    field :account_id, from: 'AccountId'
    field :partner_account_id, from: 'Partner_Account_Id__c'
  end
  class Account < ActiveForce::SObject
    has_many :opportunities, model: Foo::Opportunity
    has_many :partner_opportunities, foreign_key: :partner_account_id, model: Foo::Opportunity
  end
  class Lead < ActiveForce::SObject; end
  class Attachment < ActiveForce::SObject
    field :lead_id, from: 'Lead_Id__c'
    field :fancy_lead_id, from: 'LeadId'
    belongs_to :lead, model: Foo::Lead
    belongs_to :fancy_lead, model: Foo::Lead, foreign_key: :fancy_lead_id
  end
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
  class Account < ActiveForce::SObject
  end
  class Opportunity < ActiveForce::SObject
  end
  class User < ActiveForce::SObject
  end
  class Opportunity < ActiveForce::SObject
    field :owner_id, from: 'OwnerId'
    field :account_id, from: 'AccountId'
    belongs_to :owner, model: User, foreign_key: :owner_id, relationship_name: 'Owner'
    belongs_to :account, model: Account
  end
end
