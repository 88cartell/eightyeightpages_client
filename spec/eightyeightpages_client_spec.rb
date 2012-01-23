require 'spec_helper'

# TODO: these tests don't really test whether the functionality works.
describe EightyeightpagesClient::Query do
  before do
    @query = EightyeightpagesClient::Query.new 'test', 'localhost'
    @query.base_uri = 'test.eightyeightpages.dev'
  end

  describe "Testing SuperHash" do
    it "should acts like a hash" do
      hash = EightyeightpagesClient::SuperHash.new({'test' => 1})
      hash.respond_to?(:each).should be_true
      hash.respond_to?(:keys).should be_true
      hash[:test].should eq(1)
    end

    it "should support hashes" do
      EightyeightpagesClient::SuperHash.new({'test' => 1}).test.should eq(1)
    end

    it "should do nesting" do
      EightyeightpagesClient::SuperHash.new({'test' => {'x' => 7}}).test.x.should eq(7)
    end

    it "should do more nesting" do
      hash = {'test' => {'x' => 7, 'yellow' => [{'b' => 'hello'}, {'c' => 'onetwo'}]}}
      struct = EightyeightpagesClient::SuperHash.new(hash)
      struct.test.yellow.first.b.should eq('hello')
    end

    it "should do more nesting, it was having trouble with the y key before" do
      hash = {'test' => {'x' => 7, 'y' => [{'b' => 'hello'}, {'c' => 'onetwo'}]}}
      struct = EightyeightpagesClient::SuperHash.new(hash)
      struct.test.y.first.b.should eq('hello')
    end

    it "should work as a normal hash too" do
      hash = {'test' => {'x' => 7, 'y' => [{'b' => 'hello'}, {'c' => 'onetwo'}]}}
      struct = EightyeightpagesClient::SuperHash.new(hash)
      struct.key?('test').should be_true
      struct.test.key?('y').should be_true
    end
  end

  #describe "Perform a simple list query" do
  #  it "should return results" do
  #    @query.lachlans_pages.length.should > 1
  #  end
  #end

  #describe "Query with a where" do
  #  it "should return results" do
  #    @query.lachlans_pages.where(title: 'One').length.should eq(1)
  #  end
  #end

  #describe "Order by" do
  #  it "should return results" do
  #    @query.lachlans_pages.order_by(title: 'asc').order_by(cms_position: 'desc').length.should > 1
  #  end
  #end

  #describe "Skip some records" do
  #  it "should return some results" do
  #    @query.lachlans_pages.skip(2).length.should > 1
  #  end
  #end

  #describe "Limit records" do
  #  it "should return 2 results" do
  #    @query.lachlans_pages.limit(2).length.should eq(2)
  #  end
  #end

  #describe "Any of" do
  #  it "should return 2 records" do
  #    @query.lachlans_pages.any_of({title: 'One'}, {title: 'Two'}).length.should eq(2)
  #  end
  #end

  #describe "Any in" do
  #  it "should return some results" do
  #    @query.lachlans_pages.any_in(title: ['One', 'Two']).length.should eq(2)
  #  end
  #end
end
