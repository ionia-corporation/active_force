require 'spec_helper'

describe ActiveForce::SObject do
  describe '#table_name' do

    it 'Use the class name adding "__c"' do
      class Custom < ActiveForce::SObject
      end

      expect(Custom.table_name).to eq('Custom__c')
    end

    it 'with standard SObject types it does not add the "__c"' do
      class Account < ActiveForce::SObject
      end

      expect(Account.table_name).to eq('Account')
    end

    it 'can be enforced in the class definition' do
      class EnforcedTableName < ActiveForce::SObject
        self.table_name = 'Forced__c'
      end

      expect(EnforcedTableName.table_name).to eq('Forced__c')
    end

    it "doesn't include a namespace" do
      module Foo
        class Bar < ActiveForce::SObject
        end
      end

      expect(Foo::Bar.table_name).to eq('Bar__c')
    end
  end
end
