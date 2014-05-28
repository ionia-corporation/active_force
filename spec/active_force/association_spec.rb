require 'spec_helper'
require 'active_force/association'

describe ActiveForce::SObject do

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

      @post = Post.new
      @post.stub(:id).and_return("1")
    end

    it "should return a Query object" do
      @post.comments_query.class.should be ActiveForce::Query
    end

    describe 'to_s' do
      it "should retrun a OSQL statment" do
       @post.comments_query.to_s.should ==
         "SELECT Id FROM Comment__c WHERE Post__c = '1'"
      end
    end
  end

  describe 'has_many(options)' do

    it 'should allow to send a different query table name' do
      class Post < ActiveForce::SObject
        has_many :comments, { table: 'Comment' }
      end
      @post = Post.new
      @post.stub(:id).and_return("1")
      @post.comments_query.to_s.should ==
        "SELECT Id FROM Comment WHERE Post__c = '1'"
    end

    it 'should allow to change the foreing key' do
      class Post < ActiveForce::SObject
        has_many :comments, { foreing_key: 'Post' }
      end
      @post = Post.new
      @post.stub(:id).and_return("1")
      @post.comments_query.to_s.should ==
        "SELECT Id FROM Comment__c WHERE Post = '1'"
    end

    it 'should allow to add a where condition' do
      class Post < ActiveForce::SObject
        has_many :comments, { where: '1 = 1' }
      end
      @post = Post.new
      @post.stub(:id).and_return("1")
      @post.comments_query.to_s.should ==
        "SELECT Id FROM Comment__c WHERE 1 = 1 AND Post__c = '1'"
    end

    it 'should use a convention name for the foreing key' do
      class Comment < ActiveForce::SObject
        field :post_id,         from: 'PostId'
      end

      class Post < ActiveForce::SObject
        has_many :comments
      end

      @post = Post.new
      @post.stub(:id).and_return("1")
      @post.comments_query.to_s.should ==
        "SELECT Id FROM Comment__c WHERE PostId = '1'"
    end
  end
end