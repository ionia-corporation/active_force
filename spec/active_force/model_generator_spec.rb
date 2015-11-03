require 'hashie'
require 'spec_helper'
require 'rails/generators'
require 'generators/active_force/model/model_generator'

describe ActiveForce::ModelGenerator do

  let(:client) do
    client = double('sfdc_client')
    allow(client).to receive(:describe) do |table_name|
      Hashie::Mash.new fields: [
        { name: 'Name' },
        { name: 'CustomField__c' }
      ]
    end
    client
  end

  around do |example|
    Dir.mktmpdir do |dir|
      Dir.chdir dir do
        example.call
      end
    end
  end

  before do
    ActiveForce.sfdc_client = client
  end

  it 'generate a model file' do
    generator = described_class.new ['Account']
    generator.create_model_file
    expect(File.exist?('app/models/account.rb')).to be
    expect(File.read('app/models/account.rb')).to eq(<<-RUBY.gsub(/^\s*\|/, ''))
      |class Account < ActiveForce::SObject
      |  field :name,         from: 'Name'
      |  field :custom_field, from: 'CustomField__c'
      |end
    RUBY
  end

end
