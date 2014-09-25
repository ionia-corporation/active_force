require 'spec_helper'

describe ActiveForce::SObject do
  describe '#table_name' do
    it 'Use the class name adding "__c"' do
      expect(Custom.table_name).to eq('Custom__c')
    end

    it 'with standard SObject types it does not add the "__c"' do
      expect(Account.table_name).to eq('Account')
    end

    it 'can be enforced in the class definition' do
      expect(EnforcedTableName.table_name).to eq('Forced__c')
    end

    context 'with a namespace' do
      it "the namespace is not included" do
        expect(Foo::Bar.table_name).to eq('Bar__c')
      end

      it 'standard types are inferred correctly' do
        expect(Foo::Account.table_name).to eq('Account')
      end
    end
  end
end
