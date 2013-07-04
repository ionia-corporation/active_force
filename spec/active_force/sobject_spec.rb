require 'spec_helper'

describe ActiveForce::SObject do
  describe ".new" do
    it "create with valid values" do
      @SObject = Whizbang.new
      expect(@SObject).to be_an_instance_of Whizbang
    end
  end

  describe ".build" do
    let(:sobject_hash) { YAML.load(fixture('sobject/single_sobject_hash')) }

    it "build a valid sobject from a JSON" do
      expect(Whizbang.build sobject_hash).to be_an_instance_of Whizbang
    end
  end
end
