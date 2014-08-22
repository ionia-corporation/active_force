require 'spec_helper'

describe ActiveForce::SObject do
  let(:sobject_hash) { YAML.load(fixture('sobject/single_sobject_hash')) }
  let(:client) { double 'Client' }

  before do
    ActiveForce::SObject.stub(:sfdc_client).and_return client
  end

  describe ".new" do
    it "create with valid values" do
      @SObject = Whizbang.new
      expect(@SObject).to be_an_instance_of Whizbang
    end
  end

  describe ".build" do

    it "build a valid sobject from a JSON" do
      expect(Whizbang.build sobject_hash).to be_an_instance_of Whizbang
    end
  end

  describe ".field" do
    it "add a mappings" do
      expect(Whizbang.mappings).to include(
        checkbox: 'Checkbox_Label',
        text: 'Text_Label',
        date: 'Date_Label',
        datetime: 'DateTime_Label',
        picklist_multiselect: 'Picklist_Multiselect_Label'
      )
    end

    it "set an attribute" do
      %w[checkbox text date datetime picklist_multiselect].each do |name|
        expect(Whizbang.attribute_names).to include(name)
      end
    end

    it "uses Salesforce API naming conventions by default" do
      expect(Whizbang.mappings[:estimated_close_date]).to eq 'Estimated_Close_Date__c'
    end
  end

  describe '#update' do

    subject do
      Whizbang.new
    end

    before do
      client.should_receive(:update!).and_return('id')
    end

    it 'delegates to the Client with create!' do
      expect(subject.update({ text: 'some text' })).to be_a Whizbang
    end

  end

  describe '#create' do

    subject do
      Whizbang.new
    end

    before do
      client.should_receive(:create!).and_return('id')
    end

    it 'delegates to the Client with create!' do
      subject.create
    end

    it 'sets the id' do
      subject.create
      expect(subject.id).to eq('id')
    end

  end

  describe 'self.create' do

    before do
      client.should_receive(:create!).and_return('id')
    end

    it 'should create a new instance' do
      expect(Whizbang.create({ text: 'some text' })).to be_a Whizbang
    end

  end

  describe "#count" do
    let(:count_response){ [Restforce::Mash.new(expr0: 1)] }

    it "responds to count" do
      Whizbang.should respond_to(:count)
    end

    it "sends the query to the client" do
      expect(client).to receive(:query).and_return(count_response)
      expect(Whizbang.count).to eq(1)
    end

  end

  # describe "first" do
  #   it "should return the first value" do
  #     binding.pry
  #     expect(Whizbang.first).to eq(1)
  #   end
  # end

  describe "#find_by" do
    it "should query the client, with the SFDC field names and correctly enclosed values" do
      client.should_receive(:query).with("SELECT #{Whizbang.fields.join ', '} FROM Whizbang__c WHERE Id = 123 AND Text_Label = 'foo' LIMIT 1")
      Whizbang.find_by id: 123, text: "foo"
    end
  end

end
