require 'spec_helper'
require 'active_force/association'

describe ActiveForce::SObject do

  let :post do
    Post.new(id: "1")
  end

  let :comment do
    Comment.new(id: "1")
  end

  let :client do
    double("sfdc_client")
  end

  before do
    class Post < ActiveForce::SObject
      self.table_name = "Post__c"
    end

    class Comment < ActiveForce::SObject
      field :post_id, from: "PostId"
      self.table_name = "Comment__c"
    end

    allow(ActiveForce::SObject).to receive(:sfdc_client).and_return client
  end

  describe "has_many_query" do

    before do
      class Post < ActiveForce::SObject
        has_many :comments
      end
    end

    it "should respond to relation method" do
      expect(post).to respond_to(:comments)
    end

    it "should return a ActiveQuery object" do
      expect(post.comments).to be_a ActiveForce::ActiveQuery
    end

    describe 'to_s' do
      it "should retrun a SOQL statment" do
        soql = "SELECT Id, PostId FROM Comment__c WHERE PostId = '1'"
       expect(post.comments.to_s).to eq soql
      end
    end

    context 'when the SObject is namespaced' do
      let(:account){ Foo::Account.new(id: '1') }

      before do
        module Foo
          class Opportunity < ActiveForce::SObject
            field :account_id, from: 'AccountId'
          end

          class Account < ActiveForce::SObject
            has_many :opportunities, model: Foo::Opportunity
          end
        end
      end

      it 'correctly infers the foreign key and forms the correct query' do
        soql = "SELECT Id, AccountId FROM Opportunity WHERE AccountId = '1'"
        expect(account.opportunities.to_s).to eq soql
      end

      it 'uses an explicit foreign key if it is supplied' do
        Foo::Opportunity.field :partner_account_id, from: 'Partner_Account_Id__c'
        Foo::Account.has_many :opportunities, foreign_key: :partner_account_id, model: Foo::Opportunity
        soql = "SELECT Id, AccountId, Partner_Account_Id__c FROM Opportunity WHERE Partner_Account_Id__c = '1'"
        expect(account.opportunities.to_s).to eq soql
      end
    end
  end

  describe 'has_many(options)' do
    before do
      Post.has_many :comments
    end

    it 'should allow to send a different query table name' do
      Post.has_many :ugly_comments, { model: Comment }
      soql = "SELECT Id, PostId FROM Comment__c WHERE PostId = '1'"
      expect(post.ugly_comments.to_s).to eq soql
    end

    it 'should allow to change the foreign key' do
      Post.has_many :comments, { foreign_key: :post }
      Comment.field :post, from: 'PostId'
      soql = "SELECT Id, PostId FROM Comment__c WHERE PostId = '1'"
      expect(post.comments.to_s).to eq soql
    end

    it 'should allow to add a where condition' do
      Post.has_many :comments, { where: '1 = 1' }
      soql = "SELECT Id, PostId FROM Comment__c WHERE 1 = 1 AND PostId = '1'"
      expect(post.comments.to_s).to eq soql
    end

    it 'should use a convention name for the foreign key' do
      soql = "SELECT Id, PostId FROM Comment__c WHERE PostId = '1'"
      expect(post.comments.to_s).to eq soql
    end

  end

  describe "belongs_to" do

    before do
      allow(client).to receive(:query).and_return [Restforce::Mash.new(id: 1)]
      Comment.belongs_to :post
    end

    it "should get the resource it belongs to" do
      expect(comment.post).to be_instance_of(Post)
    end

    it "should allow to pass a foreign key as options" do
      class Comment < ActiveForce::SObject
      	field :fancy_post_id, from: 'PostId'
      	belongs_to :post, foreign_key: :fancy_post_id
      end
      allow(comment).to receive(:fancy_post_id).and_return "2"
      expect(client).to receive(:query).with("SELECT Id FROM Post__c WHERE Id = '2' LIMIT 1")
      comment.post
    end

    it 'makes only one API call when accessing the associated object' do
      expect(client).to receive(:query).once
      comment.post
      comment.post
    end

    context 'when the SObject is namespaced' do
      let(:attachment){ Foo::Attachment.new(id: '1', lead_id: '2') }
      before do
        module Foo
          class Lead < ActiveForce::SObject; end

          class Attachment < ActiveForce::SObject
            field :lead_id, from: 'Lead_Id__c'
            belongs_to :lead, model: Foo::Lead
          end
        end
      end

      it 'generates the correct query' do
        expect(client).to receive(:query).with("SELECT Id FROM Lead WHERE Id = '2' LIMIT 1")
        attachment.lead
      end

      it 'instantiates the correct object' do
        expect(attachment.lead).to be_instance_of(Foo::Lead)
      end

      context 'when given a foreign key' do
        let(:attachment){ Foo::Attachment.new(id: '1', fancy_lead_id: '2') }
        before do
          module Foo
            class Attachment < ActiveForce::SObject
              field :fancy_lead_id, from: 'LeadId'
              belongs_to :lead, model: Foo::Lead, foreign_key: :fancy_lead_id
            end
          end
        end

        it 'generates the correct query' do
          expect(client).to receive(:query).with("SELECT Id FROM Lead WHERE Id = '2' LIMIT 1")
          attachment.lead
        end
      end
    end
  end
end
