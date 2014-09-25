require 'spec_helper'

describe ActiveForce::Mapping do
  let(:mapping){ ActiveForce::Mapping.new 'some_table' }

  describe 'field' do
    it 'should add a new attribute to the instance' do
      mapping.field :id, from: 'Id'
      expect(mapping.mappings).to eq({ id: 'Id' })
    end

    it 'sf_names should return all attributes names from salesforce' do
      mapping.field :id, from: 'Id'
      mapping.field :name, from: 'Name'
      expect(mapping.sfdc_names).to eq ['Id', 'Name']
    end
  end
end
