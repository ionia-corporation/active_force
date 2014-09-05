require 'spec_helper'

module ActiveForce
  describe SObject do
    let(:client){ double "client" }

    before do
      allow(ActiveForce::SObject).to receive(:sfdc_client).and_return client
    end

    describe '.includes' do
      context 'child to parent (belongs_to)' do
        it 'queries the API for the associated record' do
          soql = Territory.includes(:quota).where(id: '123').to_s
          expect(soql).to eq "SELECT Id, Quota__c, Quota__r.Bar_Id__c FROM Territory WHERE Id = '123'"
        end

        it "queries the API once to retrieve the object and its related one" do
          response = [{ 
            "Id" => "123", 
            "Quota__c" => "321", 
            "Quota__r" => { 
              "Bar_Id__c" => "321" 
            } 
          }]
          allow(client).to receive(:query).once.and_return response
          territory = Territory.includes(:quota).find "123"
          expect(territory.quota).to be_a Quota
          expect(territory.quota.id).to eq "321"
        end
      end
    end
  end
end
