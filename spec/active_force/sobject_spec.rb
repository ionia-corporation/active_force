require 'spec_helper'

describe ActiveForce::SObject do
  let(:sobject_hash) { YAML.load(fixture('sobject/single_sobject_hash')) }
  let(:client) { double 'Client' }

  before do
    allow(ActiveForce::SObject).to receive(:sfdc_client).and_return client
  end

  describe ".new" do
    it 'should assigns values when are passed by parameters' do
      expect(Whizbang.new({ text: 'some text' }).text).to eq 'some text'
    end
  end

  describe ".build" do
    let(:sobject){ Whizbang.build sobject_hash }

    it "build a valid sobject from a JSON" do
      expect(sobject).to be_an_instance_of Whizbang
    end

    it "sets the values' types from the sf_type" do
      expect(sobject.boolean).to be_an_instance_of TrueClass
      expect(sobject.checkbox).to be_an_instance_of FalseClass
      expect(sobject.date).to be_an_instance_of Date
      expect(sobject.datetime).to be_an_instance_of DateTime
      expect(sobject.percent).to be_an_instance_of Float
      expect(sobject.text).to be_an_instance_of String
      expect(sobject.picklist_multiselect).to be_an_instance_of String
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

    describe 'having an id' do
      it 'has one by default' do
        expect(Territory.new).to respond_to(:id)
        expect(Territory.mappings[:id]).to eq 'Id'
      end

      it 'can be overridden' do
        expect(Quota.new).to respond_to(:id)
        expect(Quota.mappings[:id]).to eq 'Bar_Id__c'
      end
    end

    context 'as: :multi_picklist' do
      before do
        class IceCream < ActiveForce::SObject
          field :flavors, as: :multi_picklist
        end
        sundae.changed_attributes.clear
        sundae.flavors = %w(chocolate vanilla strawberry)
      end

      context 'on create' do
        let(:sundae) { IceCream.new }
        it 'formats the picklist values' do
          expect(client).to receive(:create!).with('IceCream__c', {'Flavors__c' => 'chocolate;vanilla;strawberry'})
          sundae.save
        end
      end

      context 'on update' do
        let(:sundae) { IceCream.new(id: '1') }
        it 'formats the picklist values' do
          expect(client).to receive(:update!).with('IceCream__c', {'Flavors__c' => 'chocolate;vanilla;strawberry', 'Id' => '1'})
          sundae.save
        end
      end

    end
  end

  describe "CRUD" do
    subject do
      Whizbang.new(id: '1')
    end

    describe '#update' do
      before do
        expected_args = [
          Whizbang.table_name,
          {'Text_Label' => 'some text', 'Boolean_Label' => false, 'Id' => '1'}
        ]
        expect(client).to receive(:update!).with(*expected_args).and_return('id')
      end

      it 'delegates to the Client with create!' do
        expect(subject.update({ text: 'some text', boolean: false })).to be_a Whizbang
      end
    end

    describe '#create' do
      before do
        expect(client).to receive(:create!).and_return('id')
      end

      it 'delegates to the Client with create!' do
        subject.create
      end

      it 'sets the id' do
        subject.create
        expect(subject.id).to eq('id')
      end
    end

    describe "#destroy" do
      it "should send client :destroy! with its id" do
        expect(client).to receive(:destroy!).with 'Whizbang__c', '1'
        subject.destroy
      end
    end

    describe 'self.create' do
      before do
        expect(client).to receive(:create!).with(Whizbang.table_name, 'Text_Label' => 'some text', 'Updated_From__c'=>'Rails').and_return('id')
      end

      it 'should create a new instance' do
        expect(Whizbang.create({ text: 'some text' })).to be_a Whizbang
      end
    end
  end

  describe "#count" do
    let(:count_response){ [Restforce::Mash.new(expr0: 1)] }

    it "responds to count" do
      expect(Whizbang).to respond_to(:count)
    end

    it "sends the query to the client" do
      expect(client).to receive(:query).and_return(count_response)
      expect(Whizbang.count).to eq(1)
    end

  end

  describe "#find_by" do
    it "should query the client, with the SFDC field names and correctly enclosed values" do
      expect(client).to receive(:query).with("SELECT #{Whizbang.fields.join ', '} FROM Whizbang__c WHERE Id = 123 AND Text_Label = 'foo' LIMIT 1")
      Whizbang.find_by id: 123, text: "foo"
    end
  end

  describe '#reload' do
    let(:client) do
      double("sfdc_client", query: [Restforce::Mash.new(Id: 1, Name: 'Jeff')])
    end
    let(:quota){ Quota.new(id: '1') }
    let(:territory){ Territory.new(id: '1', quota_id: '1') }

    before do
      Territory.belongs_to :quota, model: Quota
      Territory.field :quota_id, from: 'Quota_Id'
      allow(ActiveForce::SObject).to receive(:sfdc_client).and_return client
    end

    it 'clears cached associations' do
      soql = "SELECT Id, Bar_Id__c FROM Quota__c WHERE Id = '1' LIMIT 1"
      expect(client).to receive(:query).twice.with soql
      allow(Territory).to receive(:find){ territory }
      territory.quota
      territory.quota
      territory.reload
      territory.quota
    end

    it "refreshes the object's attributes" do
      Territory.field :name, from: 'Name'
      territory.name = 'Walter'
      expect(territory.name).to eq 'Walter'
      territory.reload
      expect(territory.name).to eq 'Jeff'
      expect(territory.changed_attributes).to be_empty
    end

    it 'returns the same object' do
      allow(Territory).to receive(:find){ Territory.new }
      expected = territory
      expect(territory.reload).to eql expected
    end
  end

  describe '#persisted?' do
    context 'with an id' do
      let(:instance){ Territory.new(id: '00QV0000004jeqNMAT') }

      it 'returns true' do
        expect(instance).to be_persisted
      end
    end

    context 'without an id' do
      let(:instance){ Territory.new }

      it 'returns false' do
        expect(instance).to_not be_persisted
      end
    end
  end

  describe 'logger output' do
    let(:instance){ Whizbang.new }

    before do
      allow(instance).to receive(:create!).and_raise(Faraday::Error::ClientError.new(double))
    end

    it 'catches and logs the error' do
      expect(instance).to receive(:logger_output).and_return(false)
      instance.save
    end
  end
end
