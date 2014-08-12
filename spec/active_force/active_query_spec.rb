require 'spec_helper'
require 'active_force/active_query'

describe ActiveForce::ActiveQuery do
  let(:sobject){
    sobject = double("sobject")
    sobject.stub(:table_name).and_return "table_name"
    sobject.stub(:fields).and_return {}
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
end
