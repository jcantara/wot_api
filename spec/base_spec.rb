require 'spec_helper'

describe WotApi::Base do

  it "has an empty base_uri" do
    # NOTE: may remove this entirely if base_uri is just going to be set dynamically
    expect(WotApi::Base.base_uri).to eq nil
  end

  it "includes HTTParty" do
    expect(WotApi::Base.new).to be_a_kind_of(HTTParty)
  end

  describe "REGIONS" do
    WotApi::Base::REGIONS.each do |region, url|
      describe "#{region}" do
        it "has a sym region key" do
          expect(region).to be_a Symbol
        end

        it "has a string value" do
          expect(url).to be_a String
        end

        it "uses https" do
          expect(URI.parse(url).scheme).to eq 'https'
        end
      end
    end
  end

  describe "REGIONS2" do
    WotApi::Base::REGIONS2.each do |region, url|
      describe "#{region}" do
        it "has a sym region key" do
          expect(region).to be_a Symbol
        end

        it "has a string value" do
          expect(url).to be_a String
        end

        it "uses http" do
          expect(URI.parse(url).scheme).to eq 'http'
        end
      end
    end
  end

  describe ".clans_accounts" do
    it "calls WotApi::Base.get with endpoint and clan_id" do
      WotApi::Base.config({'na' => '123456'})
      expect(WotApi::Base).to receive(:get).with("/clans/12345/accounts", headers: {"X-Requested-With"=> "XMLHttpRequest"})
      WotApi::Base.clans_accounts(clan_id: "12345")
    end
  end

  describe ".merged_post" do
    it "calls WotApi::Base.post with endpont and merged_params output" do
      params1 = {random: 'hash'}
      params2 = {misc: 'data'}
      endpoint = '/test/endpoint/'
      expect(WotApi::Base).to receive(:merged_params).with(params1).and_return(params2)
      expect(WotApi::Base).to receive(:post).with(endpoint, {body: params2})
      WotApi::Base.merged_post(endpoint, params1)
    end
    it "has default empty hash for params" do
      expect(WotApi::Base).to receive(:merged_params).with({}).and_return({})
      allow(WotApi::Base).to receive(:post)
      WotApi::Base.merged_post('/test/nothing')
    end
  end

  describe ".config" do
    context "with a valid config" do
      it "creates hash of regions with base_uri and application_id" do
        WotApi::Base.config({'na' => '123456'})
        expect(WotApi::Base.configuration).to eq({na: {base_uri: 'https://api.worldoftanks.com', application_id: '123456'}})
      end

      it "sets first item as default region" do
        WotApi::Base.config({'na' => '123456'})
        expect(WotApi::Base.default_region).to eq :na
        WotApi::Base.config({'ru' => '444444','na' => '123456'})
        expect(WotApi::Base.default_region).to eq :ru
      end
    end

    context "with an invalid config" do
      it "raises an error" do
        expect{WotApi::Base.config({lalala: 'fake'})}.to raise_error
      end
    end
  end

  describe ".merged_params" do
    context "with a valid region parameter" do
      it "merges the params hash argument with the application_id from the specified region" do
        arguments = {a: 'hi', b: 'test', c: 3, region: 'na'}
        WotApi::Base.config(na: 'abc123')
        expect(WotApi::Base.merged_params(arguments)).to eq({a: 'hi', b: 'test', c: 3}.merge(application_id: 'abc123'))
      end
    end

    context "with an invalid region parameter" do
      it "raises an exception" do
        arguments = {a: 'hi', b: 'test', c: 3, region: 'banana'}
        WotApi::Base.config(na: 'abc123')
        expect{WotApi::Base.merged_params(arguments)}.to raise_error
      end
    end

    context "with no region parameter" do
      it "merges the params hash argument with the application_id from the default first region" do
        arguments = {a: 'hi', b: 'test', c: 3}
        WotApi::Base.config(na: 'abc123')
        expect(WotApi::Base.merged_params(arguments)).to eq arguments.merge(application_id: 'abc123')
      end
    end

    it "sets base_uri" do
      WotApi::Base.config(na: 'abc123')
      WotApi::Base.merged_params({})
      expect(WotApi::Base.base_uri).to eq WotApi::Base::REGIONS[:na]

      WotApi::Base.config(ru: 'abc123')
      WotApi::Base.merged_params({})
      expect(WotApi::Base.base_uri).to eq WotApi::Base::REGIONS[:ru]
    end
  end

  describe "endpoint methods via method_missing" do
    before(:example) do
      WotApi::Base.config({na: '123456'})
    end

    it "posts to the specified endpoint" do
      expect(WotApi::Base).to receive(:post).with("/wot/thing/stuff/", kind_of(Hash)).and_return({'data' => true})
      WotApi::Base.thing_stuff(a: 'test')
    end

    it "accepts a hash of arguments to post to the endpoint and merges them with the application_id" do
      arguments = {a: 'hi', b: 'test', c: 3}
      expect(WotApi::Base).to receive(:post).with("/wot/thing/stuff/", body: arguments.merge(application_id: '123456')).and_return({'data' => true})
      WotApi::Base.thing_stuff(arguments)
    end

    context "with a valid response" do
      it "receives a response from api with data in an Array or Hash" do
        FakeWeb.register_uri(:post, "#{WotApi::Base.base_uri}/wot/thing/stuff/", :response => File.join(File.dirname(__FILE__), 'fixtures', "success.json"))
        expect(WotApi::Base.thing_stuff).to be_a_kind_of(Array)
      end
    end

    context "with an invalid response" do
      it "raises an exception" do
        FakeWeb.register_uri(:post, "#{WotApi::Base.base_uri}/wot/thing/stuff/", :response => File.join(File.dirname(__FILE__), 'fixtures', "error.json"))
        expect{WotApi::Base.thing_stuff}.to raise_error(WotApi::ResponseError)
      end

      it "includes the error message from WoT in the exception" do
        FakeWeb.register_uri(:post, "#{WotApi::Base.base_uri}/wot/thing/stuff/", :response => File.join(File.dirname(__FILE__), 'fixtures', "error.json"))
        expect{WotApi::Base.thing_stuff}.to raise_error(WotApi::ResponseError, 'APPLICATION_ID_NOT_SPECIFIED')
      end
    end

    context "with an invalid endpoint" do
      it "raises connection exception" do
        allow(WotApi::Base).to receive(:post).and_raise(HTTParty::Error)
        expect{WotApi::Base.thing_fake}.to raise_error(WotApi::ConnectionError)
      end
    end
  end
end
