require 'spec_helper'

describe WotApi::Wrapper do

  it { is_expected.to be_a_kind_of(HTTParty) }

  describe ".wot_api_post" do
    context "with a connection error" do
      before(:example) do
        FakeWeb.clean_registry
        WotApi.config({'na' => '123456'})
      end
      it "raises WotApi::ConnectionError" do
        expect{ WotApi::Wrapper.wot_api_post(:thing_stuff, {}) }.to raise_error WotApi::ConnectionError
      end
    end

    context "with invalid endpoint" do
      before(:example) do
        FakeWeb.register_uri(:post, "https://api.worldoftanks.com/wot/thing/stuff/", :response => File.join(File.dirname(__FILE__), 'fixtures', "error.json"))
        WotApi.config({'na' => '123456'})
      end
      it "raises WotApi::ResponseError" do
        expect{ WotApi::Wrapper.wot_api_post(:thing_stuff, {}) }.to raise_error WotApi::ResponseError
      end
    end

    context "with valid endpoint" do
      before(:example) do
        FakeWeb.register_uri(:post, "https://api.worldoftanks.com/wot/thing/stuff/", :response => File.join(File.dirname(__FILE__), 'fixtures', "success.json"))
        WotApi.config({'na' => '123456'})
      end
      it "returns an array" do
        expect(WotApi::Wrapper.wot_api_post(:thing_stuff, {})).to be_an Array
      end
    end

    context "with a valid endpoint on a different path header" do
      before(:example) do
        FakeWeb.register_uri(:post, "https://api.worldoftanks.com/wgn/misc/etc/", :response => File.join(File.dirname(__FILE__), 'fixtures', "success.json"))
        WotApi.config({'na' => '123456'})
      end
      it "returns an array" do
        expect(WotApi::Wrapper.wot_api_post(:wgn_misc_etc, {})).to be_an Array
      end
    end
  end

  describe ".wot_web_get" do
    context "with a connection error" do
      before(:example) do
        FakeWeb.clean_registry
        WotApi.config({'na' => '123456'})
      end
      it "raises WotApi::ConnectionError" do
        expect{ WotApi::Wrapper.wot_web_get('/endpoint', {}) }.to raise_error WotApi::ConnectionError
      end
    end
    
    context "with a valid endpoint" do
      before(:example) do
        FakeWeb.register_uri(:get, "http://na.wargaming.net/endpoint", :response => File.join(File.dirname(__FILE__), 'fixtures', "success.json"))
        WotApi.config({'na' => '123456'})
      end
      it "returns result of get" do
        expect(WotApi::Wrapper.wot_web_get('/endpoint', {})).to eq({"status"=>"ok","count"=>0,"data"=>[]})
      end
    end
  end

  describe ".valid_endpoint?" do
    it "returns true for endponts like prefix _underscore_ suffix" do
      expect(WotApi::Wrapper.valid_endpoint?(:test_things)).to eq true
    end
    it "returns true for three-part endpoints" do
      expect(WotApi::Wrapper.valid_endpoint?(:what_ever_dude)).to eq true
    end
    it "returns false for other stuff" do
      expect(WotApi::Wrapper.valid_endpoint?(:things)).to eq false
      expect(WotApi::Wrapper.valid_endpoint?(:stuff_blah_things_and)).to eq false
      expect(WotApi::Wrapper.valid_endpoint?(:whee_)).to eq false
    end
  end

end
