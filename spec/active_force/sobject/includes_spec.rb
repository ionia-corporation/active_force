require 'spec_helper'

module ActiveForce
  describe SObject do
    let(:client){ double "client" }

    before do
      allow(ActiveForce::SObject).to receive(:sfdc_client).and_return client
    end

    describe '.includes' do
      context 'belongs_to' do
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

          context 'child to several parents' do
            it 'queries the API for associated records' do
              soql = Salesforce::Territory.includes(:quota, :widget).where(id: '123').to_s
              expect(soql).to eq "SELECT Id, QuotaId, WidgetId, Quota__r.Id, Tegdiw__r.Id FROM Territory WHERE Id = '123'"
            end

            it "queries the API once to retrieve the object and its assocations" do
              response = [{
                "Id"       => "123",
                "QuotaId"  => "321",
                "WidgetId" => "321",
                "Quota__r" => {
                  "Id" => "321"
                },
                "Tegdiw__r" => {
                  "Id" => "321"
                }
              }]
              allow(client).to receive(:query).once.and_return response
              territory = Salesforce::Territory.includes(:quota, :widget).find "123"
              expect(territory.quota).to be_a Salesforce::Quota
              expect(territory.quota.id).to eq "321"
              expect(territory.widget).to be_a Salesforce::Widget
              expect(territory.widget.id).to eq "321"
            end
          end
        end
      end

      context 'has_many' do
        context 'with standard objects' do
          it 'formulates the correct SOQL query' do
            soql = Account.includes(:opportunities).where(id: '123').to_s
            expect(soql).to eq "SELECT Id, OwnerId, (SELECT Id, AccountId FROM Opportunities) FROM Account WHERE Id = '123'"
          end

          it 'builds the associated objects and caches them' do
            response = [{
              'Id' => '123',
              'Opportunities' => [
                {'Id' => '213', 'AccountId' => '123'},
                {'Id' => '214', 'AccountId' => '123'}
              ]
            }]
            allow(client).to receive(:query).once.and_return response
            account = Account.includes(:opportunities).find '123'
            expect(account.opportunities).to be_an Array
            expect(account.opportunities.all? { |o| o.is_a? Opportunity }).to eq true
          end
        end

        context 'with custom objects' do
          it 'formulates the correct SOQL query' do
            soql = Quota.includes(:prez_clubs).where(id: '123').to_s
            expect(soql).to eq "SELECT Id, Bar_Id__c, (SELECT Id, QuotaId FROM PrezClubs__r) FROM Quota__c WHERE Bar_Id__c = '123'"
          end

          it 'builds the associated objects and caches them' do
            response = [{
              'Id' => '123',
              'PrezClubs__r' => [
                {'Id' => '213', 'QuotaId' => '123'},
                {'Id' => '214', 'QuotaId' => '123'}
              ]
            }]
            allow(client).to receive(:query).once.and_return response
            account = Quota.includes(:prez_clubs).find '123'
            expect(account.prez_clubs).to be_an Array
            expect(account.prez_clubs.all? { |o| o.is_a? PrezClub }).to eq true
          end
        end

        context 'mixing standard and custom objects' do
          it 'formulates the correct SOQL query' do
            soql = Quota.includes(:territories, :prez_clubs).where(id: '123').to_s
            expect(soql).to eq "SELECT Id, Bar_Id__c, (SELECT Id, Quota__c FROM Territories), (SELECT Id, QuotaId FROM PrezClubs__r) FROM Quota__c WHERE Bar_Id__c = '123'"
          end

          it 'builds the associated objects and caches them' do
            response = [{
              'Id' => '123',
              'PrezClubs__r' => [
                {'Id' => '213', 'QuotaId' => '123'},
                {'Id' => '214', 'QuotaId' => '123'}
              ],
              'Territories' => [
                {'Id' => '213', 'Quota__c' => '123'},
                {'Id' => '214', 'Quota__c' => '123'}
              ]
            }]
            allow(client).to receive(:query).once.and_return response
            account = Quota.includes(:territories, :prez_clubs).find '123'
            expect(account.prez_clubs).to be_an Array
            expect(account.prez_clubs.all? { |o| o.is_a? PrezClub }).to eq true
            expect(account.territories).to be_an Array
            expect(account.territories.all? { |o| o.is_a? Territory }).to eq true
          end
        end

        context 'with namespaced SObjects' do
          it 'formulates the correct SOQL query' do
            soql = Salesforce::Quota.includes(:prez_clubs).where(id: '123').to_s
            expect(soql).to eq "SELECT Id, (SELECT Id, QuotaId FROM PrezClubs__r) FROM Quota__c WHERE Id = '123'"
          end

          it 'builds the associated objects and caches them' do
            response = [{
              'Id' => '123',
              'PrezClubs__r' => [
                {'Id' => '213', 'QuotaId' => '123'},
                {'Id' => '214', 'QuotaId' => '123'}
              ]
            }]
            allow(client).to receive(:query).once.and_return response
            account = Salesforce::Quota.includes(:prez_clubs).find '123'
            expect(account.prez_clubs).to be_an Array
            expect(account.prez_clubs.all? { |o| o.is_a? Salesforce::PrezClub }).to eq true
          end
        end
      end

      describe 'mixing belongs_to and has_many' do
        it 'formulates the correct SOQL query' do
          soql = Account.includes(:opportunities, :owner).where(id: '123').to_s
          expect(soql).to eq "SELECT Id, OwnerId, (SELECT Id, AccountId FROM Opportunities), Owner__r.Id FROM Account WHERE Id = '123'"
        end

        it 'builds the associated objects and caches them' do
          response = [{
            'Id' => '123',
            'Opportunities' => [
              {'Id' => '213', 'AccountId' => '123'},
              {'Id' => '214', 'AccountId' => '123'}
            ],
            'Owner__r' => {
              'Id' => '321'
            }
          }]
          allow(client).to receive(:query).once.and_return response
          account = Account.includes(:opportunities).find '123'
          expect(account.opportunities).to be_an Array
          expect(account.opportunities.all? { |o| o.is_a? Opportunity }).to eq true
          expect(account.owner).to be_a Owner
          expect(account.owner.id).to eq '321'
        end
      end
    end
  end
end
