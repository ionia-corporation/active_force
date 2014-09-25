require 'spec_helper'

describe ActiveForce::Table do
  describe '#table_name' do
    let(:table) { ActiveForce::Table }

    it 'Use the class name adding "__c"' do
      expect(table.new('Custom').name).to eq('Custom__c')
    end

    it 'with standard SObject types it does not add the "__c"' do
      expect(table.new('Account').name).to eq('Account')
    end

    context 'with a namespace' do
      it "the namespace is not included" do
        expect(table.new('Foo::Bar').name).to eq('Bar__c')
      end

      it 'standard types are inferred correctly' do
        expect(table.new('Foo::Account').name).to eq('Account')
      end
    end
  end
end
