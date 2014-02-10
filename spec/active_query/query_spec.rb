require 'spec_helper'
require 'active_force/query'

describe ActiveForce::Query do

  before do
    @query = ActiveForce::Query.new 'table_name'
    @query.fields ['name', 'etc']
  end

  after do
  end

  describe ".all" do
    it "table should return table name" do
      @query.all.table.should be(@query.table)
    end

    it "fields should return fields" do
      @query.all.fields.should == @query.fields
    end
  end

  describe ".all.to_s" do
    it "should return a query for all records" do
      @query.all.to_s.should == "SELECT Id, name, etc FROM table_name"
    end

    it "should ignore dupicated attributes in select statment" do
      @query.fields ['Id', 'name', 'etc']
      @query.all.to_s.should == "SELECT Id, name, etc FROM table_name"
    end
  end

  describe ".where" do
    it "should add a where condition to a query" do
      @query.where("name like '%a%'").to_s.should == "SELECT Id, name, etc FROM table_name WHERE name like '%a%'"
    end

    it "should add multiples conditions to a query" do
      @query.where("condition1 = 1").where("condition2 = 2").to_s.should ==
        "SELECT Id, name, etc FROM table_name WHERE condition1 = 1 AND condition2 = 2"
    end
  end

  describe ".limit" do
    it "should add a limit to a query" do
      @query.limit("25").to_s.should == "SELECT Id, name, etc FROM table_name LIMIT 25"
    end
  end

  describe ".limit_value" do
    it "should return the limit value" do
      @query.limit(4)
      @query.limit_value.should == 4
    end
  end

  describe ".offset" do
    it "should add an offset to a query" do
      @query.offset(4).to_s.should == "SELECT Id, name, etc FROM table_name OFFSET 4"
    end
  end

  describe ".offset_value" do
    it "should return the offset value" do
      @query.offset(4)
      @query.offset_value.should == 4
    end
  end

  describe ".find.to_s" do
    it "should return a query for 1 record" do
      @query.find(2).to_s.should == "SELECT Id, name, etc FROM table_name WHERE Id = '2' LIMIT 1"
    end
  end

  describe ".order" do
    it "should add a order condition in the statment" do
      @query.order("name desc").to_s.should == "SELECT Id, name, etc FROM table_name ORDER BY name desc"
    end

    it "should add a order condition in the statment with WHERE and LIMIT" do
      @query.where("condition1 = 1").order("name desc").limit(1).to_s.should == 
        "SELECT Id, name, etc FROM table_name WHERE condition1 = 1 ORDER BY name desc LIMIT 1"
    end
  end

  describe '.join' do

    before do
      @join = ActiveForce::Query.new 'join_table_name'
      @join.fields ['name', 'etc']
    end

    it 'sould add another select statment on the current select' do
      @query.join(@join).to_s.should ==
        'SELECT Id, name, etc, (SELECT Id, name, etc FROM join_table_name) FROM table_name'
    end
  end
end