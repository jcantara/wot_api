require 'spec_helper'

describe WotApi::Base do

  it "has the correct base_uri" do
    expect(WotApi::Base.base_uri).to eq 'https://api.worldoftanks.com'
  end

  it "includes HTTParty" do
    expect(WotApi::Base.new).to be_a_kind_of(HTTParty)
  end

  describe "ENDPOINTS" do
    WotApi::Base::ENDPOINTS.each do |endpoint|
      describe "#{endpoint}" do
        it "starts and ends with a slash" do
          expect(endpoint[0]).to eq '/'
          expect(endpoint[-1]).to eq '/'
        end
      end
    end
  end

  describe ".application_id=" do
    it "stores value to application_id class variable" do
      WotApi::Base.application_id = '12345'
      expect(WotApi::Base.application_id).to eq '12345'
    end

    it "updates value in application_id when set multiple times" do
      WotApi::Base.application_id = 'aaaaa'
      expect(WotApi::Base.application_id).to eq 'aaaaa'
      WotApi::Base.application_id = '54321'
      expect(WotApi::Base.application_id).to eq '54321'
    end

    #it "sets the httparty default_params hash application_id key" do
    #  WotApi::Base.application_id = '22222'
    #  expect(WotApi::Base.default_params[:application_id]).to eq '22222'
    #end
  end

  describe ".pathname" do
    it "removes 'wot' and changes slashes to underscores" do
      expect(WotApi::Base.pathname('/wot/thing/stuff')).to eq "thing_stuff"
      expect(WotApi::Base.pathname('api/endpoint')).to eq "api_endpoint"
      expect(WotApi::Base.pathname('/wot/blah/path/')).to eq 'blah_path'
    end
  end

  describe ".merged_params" do
    it "merges the params hash argument with the application_id" do
      arguments = {a: 'hi', b: 'test', c: 3}
      WotApi::Base.application_id = 'abc123'
      expect(WotApi::Base.merged_params(arguments)).to eq arguments.merge(application_id: 'abc123')
    end
  end

  describe "dynamic endpoint class methods" do
    WotApi::Base::ENDPOINTS.each do |endpoint|
      method_name = WotApi::Base.pathname(endpoint)
      describe ".#{method_name}" do
        it "creates a method named #{method_name}" do
          expect(WotApi::Base.respond_to?(method_name.to_sym)).to eq true
        end

        it "posts to the endpoint #{endpoint}" do
          expect(WotApi::Base).to receive(:post).exactly(1).times
          WotApi::Base.send(method_name.to_sym)
        end

        it "accepts a hash of arguments to post to the endpoint and merges them with the application_id" do
          arguments = {a: 'hi', b: 'test', c: 3}
          WotApi::Base.application_id = '123456'
          expect(WotApi::Base).to receive(:post).with(endpoint, body: arguments.merge(application_id: WotApi::Base.application_id)).exactly(1).times
          WotApi::Base.send(method_name.to_sym, arguments)
        end

        it "receives a response from api with data in an Array or Hash" do
          FakeWeb.register_uri(:post, "#{WotApi::Base.base_uri}#{endpoint}", :response => File.join(File.dirname(__FILE__), 'fixtures', "#{method_name}.json"))
          expect(WotApi::Base.send(method_name.to_sym)).to be_a_kind_of(Array).or be_a_kind_of(Hash)
        end
      end
    end
  end
end
