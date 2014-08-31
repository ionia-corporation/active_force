require 'spec_helper'
require 'active_force/attribute'

describe ActiveForce::Attribute do

  let(:attribute) { ActiveForce::Attribute }

  describe 'initialize' do

    let(:some_field) { attribute.new(:some_field) }

    it 'should set "from" and "as" as default' do
      expect(some_field.from).to eq 'Some_Field__c'
      expect(some_field.as).to eq :string
    end

    it 'should take values from the option parameter' do
      other_field = attribute.new(:other_field, from: 'OT__c', as: :integer)
      expect(other_field.from).to eq 'OT__c'
      expect(other_field.as).to eq :integer
    end

  end

  describe 'when the attribute is' do

    it 'a multipick should return all values as 1 string separated with ";"' do
      names = attribute.new(:names, as: :multi_picklist)
      names.value = ['olvap', 'eloy']
      expect(names.value_for_hash).to eq 'olvap;eloy'
    end

  end

end
