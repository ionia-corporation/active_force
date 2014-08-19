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

    ActiveForce::SObject.stub(:sfdc_client).and_return client
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
      it "should retrun a OSQL statment" do
       post.comments.to_s.should ==
         "SELECT Id FROM Comment__c WHERE Post__c = '1'"
      end
    end

  end

  describe 'has_many(options)' do

    it 'should allow to send a different query table name' do
      Post.has_many :ugly_comments, { model: Comment }
      post.comments.to_s.should ==
        "SELECT Id FROM Comment__c WHERE Post__c = '1'"
    end

    it 'should allow to change the foreign key' do
      Post.has_many :comments, { foreign_key: 'Post' }
      post.comments.to_s.should ==
        "SELECT Id FROM Comment__c WHERE Post = '1'"
    end

    it 'should allow to add a where condition' do
      Post.has_many :comments, { where: '1 = 1' }
      post.comments.to_s.should ==
        "SELECT Id FROM Comment__c WHERE 1 = 1 AND Post__c = '1'"
    end

    it 'should use a convention name for the foreign key' do
      Comment.field :post_id, from: 'PostId'
      Post.has_many :comments
      post.comments.to_s.should ==
        "SELECT Id, PostId FROM Comment__c WHERE PostId = '1'"
    end

  end

  describe "belongs_to" do

    before do
      Comment.belongs_to :post
      client.stub(:query).and_return Restforce::Mash.new(id: 1)
    end

    it "should get the resource it belongs to" do
      expect(comment.post).to be_instance_of(Post)
    end

    it "should allow to pass a foreign key as options" do
      Comment.belongs_to :post, foreign_key: :fancy_post_id
      comment.stub(:fancy_post_id).and_return "1"
      client.should_receive(:query).with("SELECT Id FROM Post__c WHERE Id = '1' LIMIT 1")
      comment.post
    end

  end
end
