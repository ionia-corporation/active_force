require 'spec_helper'
require 'active_force/sobject'

describe ActiveForce::SObject do
  let(:client) { double 'Client', create!: 'id' }

  before do
    allow(ActiveForce::SObject).to receive(:sfdc_client).and_return client
  end

  describe "save" do

    it 'call action callback when save a record' do
      class Whizbang

        field :updated_from
        field :dirty_attribute

        before_save :set_as_updated_from_rails
        after_save :mark_dirty

        private

        def set_as_updated_from_rails
          self.updated_from = 'Rails'
        end

        def mark_dirty
          self.dirty_attribute = true
        end

      end

      whizbang = Whizbang.new
      whizbang.save
      expect(whizbang.updated_from).to eq 'Rails'
      expect(whizbang.dirty_attribute).to eq true
      expect(whizbang.changed.include? 'dirty_attribute').to eq true
      expect(whizbang.changed.include? 'updated_from').to eq false
    end
  end
end