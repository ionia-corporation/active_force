require 'spec_helper'
require 'active_force/active_query'

describe ActiveForce::ActiveQuery do
  let(:sobject){
    sobject = double("sobject")
    sobject.stub(:table_name).and_return "table_name"
    sobject.stub(:fields).and_return []
    sobject.stub(:mappings).and_return({field: "Field__c"})
    sobject
  }

  let(:client){
    double("client")
  }

  before do
    @active_query = ActiveForce::ActiveQuery.new(sobject)
    @active_query.stub(:sfdc_client).and_return client
    @active_query.stub(:build).and_return Object.new
  end

  describe "to_a" do
    before do
      expect(client).to receive(:query)
    end

    it "should return an array of objects" do
      result = @active_query.where("Text_Label = 'foo'").to_a
      expect(result).to be_a Array
    end

    it "should allow to chain query methods" do
      result = @active_query.where("Text_Label = 'foo'").where("Checkbox_Label = true").to_a
      expect(result).to be_a Array
    end
  end

  describe "condition mapping" do
    it "maps conditions for a .where" do
      @active_query.where(field: 123)
      expect(@active_query.to_s).to eq("SELECT Id FROM table_name WHERE Field__c = 123")
    end

    it "encloses the value in quotes if it's a string" do
      @active_query.where field: "hello"
      expect(@active_query.to_s).to end_with("Field__c = 'hello'")
    end
      

  end

  describe "#find_by" do
    it "should query the client, with the SFDC field names and correctly enclosed values" do
      expect(client).to receive :query
      @active_query.find_by field: 123
      expect(@active_query.to_s).to eq "SELECT Id FROM table_name WHERE Field__c = 123 LIMIT 1"
    end
  end
end
