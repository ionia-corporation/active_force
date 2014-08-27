require 'spec_helper'
require 'active_force/active_query'

describe ActiveForce::ActiveQuery do
  let(:sobject){
    sobject = double("sobject")
    allow(sobject).to receive(:table_name).and_return "table_name"
    allow(sobject).to receive(:fields).and_return []
    allow(sobject).to receive(:mappings).and_return({field: "Field__c"})
    sobject
  }

  let(:client){
    double("client")
  }

  let(:active_query){ ActiveForce::ActiveQuery.new(sobject) }

  before do
    allow(active_query).to receive(:sfdc_client).and_return client
    allow(active_query).to receive(:build).and_return Object.new
  end

  describe "to_a" do
    before do
      expect(client).to receive(:query)
    end

    it "should return an array of objects" do
      result = active_query.where("Text_Label = 'foo'").to_a
      expect(result).to be_a Array
    end

    it "should allow to chain query methods" do
      result = active_query.where("Text_Label = 'foo'").where("Checkbox_Label = true").to_a
      expect(result).to be_a Array
    end
  end

  describe "condition mapping" do
    it "maps conditions for a .where" do
      active_query.where(field: 123)
      expect(active_query.to_s).to eq("SELECT Id FROM table_name WHERE Field__c = 123")
    end

    it "encloses the value in quotes if it's a string" do
      active_query.where field: "hello"
      expect(active_query.to_s).to end_with("Field__c = 'hello'")
    end

    it "puts NULL when a field is set as nil" do
      active_query.where field: nil
      expect(active_query.to_s).to end_with("Field__c = NULL")
    end
  end

  describe "#find_by" do
    it "should query the client, with the SFDC field names and correctly enclosed values" do
      expect(client).to receive :query
      active_query.find_by field: 123
      expect(active_query.to_s).to eq "SELECT Id FROM table_name WHERE Field__c = 123 LIMIT 1"
    end
  end

  describe "responding as an enumerable" do
    before do
      expect(active_query).to receive(:to_a).and_return([])
    end

    it "should call to_a when receiving each" do
      active_query.each {}
    end

    it "should call to_a when receiving map" do
      active_query.map {}
    end
  end
end
