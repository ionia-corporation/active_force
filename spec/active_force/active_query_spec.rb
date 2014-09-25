require 'spec_helper'

describe ActiveForce::ActiveQuery do
  let(:sobject) do
    double("sobject", {
      table_name: "table_name",
      fields: [],
      mappings: mappings
    })
  end
  let(:mappings){ { field: "Field__c", other_field: "Other_Field" } }
  let(:client){ double("client") }
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

  describe "select only some field using mappings" do
    it "should return a query only with selected field" do
      active_query.select(:field)
      expect(active_query.to_s).to eq("SELECT Field__c FROM table_name")
    end
  end

  describe "condition mapping" do
    it "maps conditions for a .where" do
      active_query.where(field: 123)
      expect(active_query.to_s).to eq("SELECT Id FROM table_name WHERE Field__c = 123")
    end

    it 'transforms an array to a WHERE/IN clause' do
      active_query.where(field: ['foo', 'bar'])
      expect(active_query.to_s).to eq("SELECT Id FROM table_name WHERE Field__c IN ('foo','bar')")
    end

    it "encloses the value in quotes if it's a string" do
      active_query.where field: "hello"
      expect(active_query.to_s).to end_with("Field__c = 'hello'")
    end

    it "puts NULL when a field is set as nil" do
      active_query.where field: nil
      expect(active_query.to_s).to end_with("Field__c = NULL")
    end

    describe 'bind parameters' do
      let(:mappings) do
        super().merge({
          other_field: 'Other_Field__c',
          name: 'Name'
        })
      end

      it 'accepts bind parameters' do
        active_query.where('Field__c = ?', 123)
        expect(active_query.to_s).to eq("SELECT Id FROM table_name WHERE Field__c = 123")
      end

      it 'accepts nil bind parameters' do
        active_query.where('Field__c = ?', nil)
        expect(active_query.to_s).to eq("SELECT Id FROM table_name WHERE Field__c = NULL")
      end

      it 'accepts multiple bind parameters' do
        active_query.where('Field__c = ? AND Other_Field__c = ? AND Name = ?', 123, 321, 'Bob')
        expect(active_query.to_s).to eq("SELECT Id FROM table_name WHERE Field__c = 123 AND Other_Field__c = 321 AND Name = 'Bob'")
      end

      it 'complains when there given an incorrect number of bind parameters' do
        expect{
          active_query.where('Field__c = ? AND Other_Field__c = ? AND Name = ?', 123, 321)
        }.to raise_error(ActiveForce::PreparedStatementInvalid, 'wrong number of bind variables (2 for 3)')
      end

      context 'named bind parameters' do
        it 'accepts bind parameters' do
          active_query.where('Field__c = :field', field: 123)
          expect(active_query.to_s).to eq("SELECT Id FROM table_name WHERE Field__c = 123")
        end

        it 'accepts nil bind parameters' do
          active_query.where('Field__c = :field', field: nil)
          expect(active_query.to_s).to eq("SELECT Id FROM table_name WHERE Field__c = NULL")
        end

        it 'accepts multiple bind parameters' do
          active_query.where('Field__c = :field AND Other_Field__c = :other_field AND Name = :name', field: 123, other_field: 321, name: 'Bob')
          expect(active_query.to_s).to eq("SELECT Id FROM table_name WHERE Field__c = 123 AND Other_Field__c = 321 AND Name = 'Bob'")
        end

        it 'accepts multiple bind parameters orderless' do
          active_query.where('Field__c = :field AND Other_Field__c = :other_field AND Name = :name', name: 'Bob', other_field: 321, field: 123)
          expect(active_query.to_s).to eq("SELECT Id FROM table_name WHERE Field__c = 123 AND Other_Field__c = 321 AND Name = 'Bob'")
        end

        it 'complains when there given an incorrect number of bind parameters' do
          expect{
            active_query.where('Field__c = :field AND Other_Field__c = :other_field AND Name = :name', field: 123, other_field: 321)
          }.to raise_error(ActiveForce::PreparedStatementInvalid, 'missing value for :name in Field__c = :field AND Other_Field__c = :other_field AND Name = :name')
        end
      end
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

  describe "prevent SOQL injection attacks" do
    let(:mappings){ { quote_field: "QuoteField", backslash_field: "Backslash_Field__c", number_field: "NumberField" } }
    let(:quote_input){ "' OR Id!=NULL OR Id='" }
    let(:backslash_input){ "\\" }
    let(:number_input){ 123 }
    let(:expected_query){ "SELECT Id FROM table_name WHERE Backslash_Field__c = '\\\\' AND NumberField = 123 AND QuoteField = ''' OR Id!=NULL OR Id='''" }

    it 'escapes quotes and backslashes in bind parameters' do
      active_query.where('Backslash_Field__c = :backslash_field AND NumberField = :number_field AND QuoteField = :quote_field', number_field: number_input, backslash_field: backslash_input, quote_field: quote_input)
      expect(active_query.to_s).to eq(expected_query)
    end

    it 'escapes quotes and backslashes in named bind parameters' do
      active_query.where('Backslash_Field__c = ? AND NumberField = ? AND QuoteField = ?', backslash_input, number_input, quote_input)
      expect(active_query.to_s).to eq(expected_query)
    end

    it 'escapes quotes and backslashes in hash conditions' do
      active_query.where(backslash_field: backslash_input, number_field: number_input, quote_field: quote_input)
      expect(active_query.to_s).to eq(expected_query)
    end
  end
end
