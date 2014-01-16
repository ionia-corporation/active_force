require 'spec_helper'
require 'active_force/association'

describe ActiveForce::SObject do

  before do
    @klass = ActiveForce::SObject
    Comment = ActiveForce::SObject
  end

  describe "has_many" do

    before do
      @klass.has_many :comments, {as: "asdsad"}
      @post = @klass.new
      @post.table_name = "Post__c"
      @post.stub(:id).and_return("1")
    end

    it "should retrun a Query object" do
      @post.comments.class.should be ActiveForce::Query
    end

    describe 'to_s' do
      it "should retrun a OSQL statment" do
       @post.comments.to_s.should ==
         "SELECT Id FROM Comment__c WHERE Post__c = '1'"
      end
    end
  end

  describe 'has_many(options)' do

    it 'should allow to send a different query table name' do
      @klass.has_many :comments, { table: 'Comment' }
      @post = @klass.new
      @post.table_name = "Post__c"
      @post.stub(:id).and_return("1")
      @post.comments.to_s.should ==
        "SELECT Id FROM Comment WHERE Post__c = '1'"
    end

    it 'should allow to change the foreing key' do
      @klass.has_many :comments, { foreing_key: 'Post' }
      @post = @klass.new
      @post.table_name = "Post__c"
      @post.stub(:id).and_return("1")
      @post.comments.to_s.should ==
        "SELECT Id FROM Comment__c WHERE Post = '1'"
    end
  end
end