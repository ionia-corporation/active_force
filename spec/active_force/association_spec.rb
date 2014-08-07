require 'spec_helper'
require 'active_force/association'

describe ActiveForce::SObject do

  let :post do
    post = Post.new
    post.stub(:id).and_return "1"
    post
  end

  let :comment do
    comment = Comment.new
    comment.stub(:id).and_return "1"
    comment.stub(:post_id).and_return "1"
    comment
  end

  let :client do
    double("sfdc_client")
  end

  before do
    class Post < ActiveForce::SObject
      self.table_name = "Post__c"
    end

    class Comment < ActiveForce::SObject
      self.table_name = "Comment__c"
    end

  end

  describe "has_many_query" do

    before do
      class Post < ActiveForce::SObject
        has_many :comments
      end
    end

    it "should return a Query object" do
      post.comments_query.class.should be ActiveForce::Query
    end

    describe 'to_s' do
      it "should retrun a OSQL statment" do
       post.comments_query.to_s.should ==
         "SELECT Id FROM Comment__c WHERE Post__c = '1'"
      end
    end
  end

  describe 'has_many(options)' do

    it 'should allow to send a different query table name' do
      Post.has_many :comments, { table: 'Comment' }
      post.comments_query.to_s.should ==
        "SELECT Id FROM Comment WHERE Post__c = '1'"
    end

    it 'should allow to change the foreign key' do
      Post.has_many :comments, { foreign_key: 'Post' }
      post.comments_query.to_s.should ==
        "SELECT Id FROM Comment__c WHERE Post = '1'"
    end

    it 'should allow to add a where condition' do
      Post.has_many :comments, { where: '1 = 1' }
      post.comments_query.to_s.should ==
        "SELECT Id FROM Comment__c WHERE 1 = 1 AND Post__c = '1'"
    end

    it 'should use a convention name for the foreign key' do
      class Comment < ActiveForce::SObject
        field :post_id,         from: 'PostId'
      end

      class Post < ActiveForce::SObject
        has_many :comments
      end

      post.comments_query.to_s.should ==
        "SELECT Id FROM Comment__c WHERE PostId = '1'"
    end
  end
end
