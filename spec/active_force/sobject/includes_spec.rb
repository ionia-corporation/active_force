require 'spec_helper'

module ActiveForce
  describe SObject do
    before do
      Territory.belongs_to :quota
      Quota.has_many :territories
    end

    describe '.includes' do
      context 'child to parent (belongs_to)' do
        it 'queries the API for the associated record' do
          soql = Territory.includes(:quota).where(id: '123').to_s
          expect(soql).to eq "SELECT Id, Quota__r.Bar_Id__c FROM Territory WHERE Id = '123'"
        end
      end
    end
  end
end
