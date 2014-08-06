require 'spec_helper'

describe WotApi::Base do

  it "has an empty base_uri" do
    # NOTE: may remove this entirely if base_uri is just going to be set dynamically
    expect(WotApi::Base.base_uri).to eq nil
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

  describe "REGIONS" do
    WotApi::Base::REGIONS.each do |region|
      describe "#{region}" do
        it "has a sym region key" do
          expect(region[0]).to be_a Symbol
        end

        it "has a string value" do
          expect(region[1]).to be_a String
        end

        it "has a https URL value" do
          expect(URI.parse(region[1]).scheme).to eq 'https'
        end
      end
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

  describe ".pathname" do
    it "removes 'wot' and changes slashes to underscores" do
      expect(WotApi::Base.pathname('/wot/thing/stuff')).to eq "thing_stuff"
      expect(WotApi::Base.pathname('api/endpoint')).to eq "api_endpoint"
      expect(WotApi::Base.pathname('/wot/blah/path/')).to eq 'blah_path'
    end
  end

  describe ".merged_params" do
    context "with a region parameter" do
      it "merges the params hash argument with the application_id from the specified region" do
        arguments = {a: 'hi', b: 'test', c: 3, region: 'na'}
        WotApi::Base.config(na: 'abc123')
        expect(WotApi::Base.merged_params(arguments)).to eq({a: 'hi', b: 'test', c: 3}.merge(application_id: 'abc123'))
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

  describe "dynamic endpoint class methods" do
    WotApi::Base::ENDPOINTS.each do |endpoint|
      method_name = WotApi::Base.pathname(endpoint)
      describe ".#{method_name}" do
        before(:example) do
          WotApi::Base.config({na: '123456'})
        end

        it "creates a method named #{method_name}" do
          expect(WotApi::Base.respond_to?(method_name.to_sym)).to eq true
        end

        it "posts to the endpoint #{endpoint}" do
          expect(WotApi::Base).to receive(:post).and_return({'data' => true})
          WotApi::Base.send(method_name.to_sym)
        end

        it "accepts a hash of arguments to post to the endpoint and merges them with the application_id" do
          arguments = {a: 'hi', b: 'test', c: 3}
          expect(WotApi::Base).to receive(:post).with(endpoint, body: arguments.merge(application_id: '123456')).and_return({'data' => true})
          WotApi::Base.send(method_name.to_sym, arguments)
        end

        context "with a valid response" do
          it "receives a response from api with data in an Array or Hash" do
            FakeWeb.register_uri(:post, "#{WotApi::Base.base_uri}#{endpoint}", :response => File.join(File.dirname(__FILE__), 'fixtures', "#{method_name}.json"))
            expect(WotApi::Base.send(method_name.to_sym)).to be_a_kind_of(Array).or be_a_kind_of(Hash)
          end
        end

        context "with an invalid response" do
          it "raises an exception" do
            FakeWeb.register_uri(:post, "#{WotApi::Base.base_uri}#{endpoint}", :response => File.join(File.dirname(__FILE__), 'fixtures', "error.json"))
            expect{WotApi::Base.send(method_name.to_sym)}.to raise_error
          end

          it "includes the error message from WoT in the exception" do
            FakeWeb.register_uri(:post, "#{WotApi::Base.base_uri}#{endpoint}", :response => File.join(File.dirname(__FILE__), 'fixtures', "error.json"))
            expect{WotApi::Base.send(method_name.to_sym)}.to raise_error('APPLICATION_ID_NOT_SPECIFIED')
          end
        end

        context "with httparty exception" do
          it "reraises the httparty exception" do
            allow(WotApi::Base).to receive(:post).and_raise(HTTParty::Error)
            expect{WotApi::Base.send(method_name.to_sym)}.to raise_error(HTTParty::Error)
          end
        end
      end
    end
  end
end
