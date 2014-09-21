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
            "Id"       => "123",
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

        context 'with namespaced SObjects' do
          it 'queries the API for the associated record' do
            soql = Salesforce::Territory.includes(:quota).where(id: '123').to_s
            expect(soql).to eq "SELECT Id, QuotaId, WidgetId, Quota__r.Id FROM Territory WHERE Id = '123'"
          end

          it "queries the API once to retrieve the object and its related one" do
            response = [{
              "Id"       => "123",
              "QuotaId"  => "321",
              "WidgetId" => "321",
              "Quota__r" => {
                "Id" => "321"
              }
            }]
            allow(client).to receive(:query).once.and_return response
            territory = Salesforce::Territory.includes(:quota).find "123"
            expect(territory.quota).to be_a Salesforce::Quota
            expect(territory.quota.id).to eq "321"
          end

          context 'when the class name does not match the SFDC entity name' do
            let(:expected_soql) do
              "SELECT Id, QuotaId, WidgetId, Tegdiw__r.Id FROM Territory WHERE Id = '123'"
            end

            it 'queries the API for the associated record' do
              soql = Salesforce::Territory.includes(:widget).where(id: '123').to_s
              expect(soql).to eq expected_soql
            end

            it "queries the API once to retrieve the object and its related one" do
              response = [{
                "Id"        => "123",
                "WidgetId"  => "321",
                "Tegdiw__r" => {
                  "Id" => "321"
                }
              }]
              expected = expected_soql + ' LIMIT 1'
              allow(client).to receive(:query).once.with(expected).and_return response
              territory = Salesforce::Territory.includes(:widget).find "123"
              expect(territory.widget).to be_a Salesforce::Widget
              expect(territory.widget.id).to eq "321"
            end
          end
        end
      end
    end
  end
end
