require 'spec_helper'
require 'active_force/query'

describe ActiveForce::Query do

  before do
    @query = ActiveForce::Query.new 'table_name'
    @query.fields ['name', 'etc']
  end

  after do
  end

  describe '.select' do
    it 'use column sent on the select method' do
      expect(@query.select('name').all.to_s).to eq "SELECT name FROM table_name"
    end

    it 'use columns sent on the select method' do
      expect(@query.select(['id','name']).all.to_s).to eq "SELECT id, name FROM table_name"
    end
  end

  describe ".all" do
    it "table should return table name" do
      expect(@query.all.table).to eq(@query.table)
    end

    it "fields should return fields" do
      expect(@query.all.fields).to eq @query.fields
    end
  end

  describe ".all.to_s" do
    it "should return a query for all records" do
      expect(@query.all.to_s).to eq "SELECT Id, name, etc FROM table_name"
    end

    it "should ignore dupicated attributes in select statment" do
      @query.fields ['Id', 'name', 'etc']
      expect(@query.all.to_s).to eq "SELECT Id, name, etc FROM table_name"
    end
  end

  describe ".where" do
    it "should add a where condition to a query" do
      expect(@query.where("name like '%a%'").to_s).to eq "SELECT Id, name, etc FROM table_name WHERE name like '%a%'"
    end

    it "should add multiples conditions to a query" do
      expect(@query.where("condition1 = 1").where("condition2 = 2").to_s).to eq "SELECT Id, name, etc FROM table_name WHERE condition1 = 1 AND condition2 = 2"
    end
  end

  describe ".limit" do
    it "should add a limit to a query" do
      expect(@query.limit("25").to_s).to eq "SELECT Id, name, etc FROM table_name LIMIT 25"
    end
  end

  describe ".limit_value" do
    it "should return the limit value" do
      @query.limit(4)
      expect(@query.limit_value).to eq 4
    end
  end

  describe ".offset" do
    it "should add an offset to a query" do
      expect(@query.offset(4).to_s).to eq "SELECT Id, name, etc FROM table_name OFFSET 4"
    end
  end

  describe ".offset_value" do
    it "should return the offset value" do
      @query.offset(4)
      expect(@query.offset_value).to eq 4
    end
  end

  describe ".find.to_s" do
    it "should return a query for 1 record" do
      expect(@query.find(2).to_s).to eq "SELECT Id, name, etc FROM table_name WHERE Id = '2' LIMIT 1"
    end
  end

  describe ".order" do
    it "should add a order condition in the statment" do
      expect(@query.order("name desc").to_s).to eq "SELECT Id, name, etc FROM table_name ORDER BY name desc"
    end

    it "should add a order condition in the statment with WHERE and LIMIT" do
      expect(@query.where("condition1 = 1").order("name desc").limit(1).to_s).to eq "SELECT Id, name, etc FROM table_name WHERE condition1 = 1 ORDER BY name desc LIMIT 1"
    end
  end

  describe '.join' do

    before do
      @join = ActiveForce::Query.new 'join_table_name'
      @join.fields ['name', 'etc']
    end

    it 'should add another select statment on the current select' do
      expect(@query.join(@join).to_s).to eq 'SELECT Id, name, etc, (SELECT Id, name, etc FROM join_table_name) FROM table_name'
    end
  end

  describe '.first' do
    it 'should return the query for the first record' do
      expect(@query.first.to_s).to eq 'SELECT Id, name, etc FROM table_name LIMIT 1'
    end
  end

  describe '.last' do
    it 'should return the query for the last record' do
      expect(@query.last.to_s).to eq 'SELECT Id, name, etc FROM table_name ORDER BY Id DESC LIMIT 1'
    end
  end

  describe ".count" do
    it "should return the query for getting the row count" do
      expect(@query.count.to_s).to eq 'SELECT count(Id) FROM table_name'
    end

    it "should work with a condition" do
      expect(@query.where("name = 'cool'").count.to_s).to eq "SELECT count(Id) FROM table_name WHERE name = 'cool'"
    end
  end

  describe '.options' do
    it 'should add a where if the option has a where condition' do
      expect(@query.options(where: 'var = 1').to_s).to eq "SELECT Id, name, etc FROM table_name WHERE var = 1"
    end

    it 'should add a limit if the option has a limit condition' do
      expect(@query.options(limit: 1).to_s).to eq "SELECT Id, name, etc FROM table_name LIMIT 1"
    end

    it 'should add a order if the option has a order condition' do
      expect(@query.options(order: 'name desc').to_s).to eq "SELECT Id, name, etc FROM table_name ORDER BY name desc"
    end

    it 'should work with multiples options' do
      expect(@query.options(where: 'var = 1', order: 'name desc', limit: 1).to_s).to eq "SELECT Id, name, etc FROM table_name WHERE var = 1 ORDER BY name desc LIMIT 1"
    end
  end
end
