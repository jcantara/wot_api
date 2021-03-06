require 'spec_helper'

describe WotApi::Base do

  describe ".config" do
    context "with a valid config" do
      it "writes valid configuration to WotApi::Wrapper.configuration" do
        WotApi::Base.config({'na' => '123456'})
        expect(WotApi::Wrapper.configuration).to eq({na: '123456'})
      end

      it "sets first item as default region" do
        WotApi::Base.config({'na' => '123456'})
        expect(WotApi::Wrapper.default_region).to eq :na
        WotApi::Base.config({'ru' => '444444','na' => '123456'})
        expect(WotApi::Wrapper.default_region).to eq :ru
      end
    end

    context "with an invalid config" do
      it "raises an error" do
        expect{WotApi::Base.config({lalala: 'fake'})}.to raise_error WotApi::InvalidConfigError
      end
    end
  end

  describe ".method_missing" do
    it "checks WotApi::Wrapper for valid_endpoint" do
      expect(WotApi::Wrapper).to receive(:valid_endpoint?).with(:fake_method).and_return(true)
      allow(WotApi::Wrapper).to receive(:wot_api_post)
      WotApi::Base.fake_method
    end

    context "valid_endpoint true" do
      before(:example) do
        allow(WotApi::Wrapper).to receive(:valid_endpoint?).with(:fake_method).and_return(true)
      end

      it "calls WotApi::Wrapper.wot_api_post" do
        expect(WotApi::Wrapper).to receive(:wot_api_post)
        WotApi::Base.fake_method
      end

      it "calls WotApi::Wrapper.wot_api_post with method symbol and parameters" do
        expect(WotApi::Wrapper).to receive(:wot_api_post).with(:fake_method, {hi: true})
        WotApi::Base.fake_method(hi: true)
      end
    end

    context "valid_endpoint false" do
      before(:example) do
        allow(WotApi::Wrapper).to receive(:valid_endpoint?).with(:fake_method).and_return(false)
      end

      it "raises NoMethodError" do
        expect{ WotApi::Base.fake_method(stuff: true) }.to raise_error NoMethodError
      end
    end
  end

  describe ".respond_to?" do
    it "checks WotApi::Wrapper for valid_endpoint" do
      expect(WotApi::Wrapper).to receive(:valid_endpoint?).with(:fake_method).and_return(true)
      WotApi::Base.respond_to?(:fake_method)
    end

    context "valid_endpoint true" do
      before(:example) do
        allow(WotApi::Wrapper).to receive(:valid_endpoint?).with(:fake_method).and_return(true)
      end

      it "returns true" do
        expect(WotApi::Base.respond_to?(:fake_method)).to eq true
      end
    end

    context "valid_endpoint false" do
      before(:example) do
        allow(WotApi::Wrapper).to receive(:valid_endpoint?).with(:fake_method).and_return(false)
      end

      it "returns false" do
        expect(WotApi::Base.respond_to?(:fake_method)).to eq false
      end
    end
  end

  describe ".clans_accounts" do
    it "raises WotApi::InvalidArguments if clan_id not in arguments" do
      expect{ WotApi::Base.clans_accounts }.to raise_error WotApi::InvalidArguments
    end

    it "calls WotApi::Wrapper.wot_web_get with endpoint and clan_id" do
      expect(WotApi::Wrapper).to receive(:wot_web_get).with("/clans/12345/accounts", headers: {"X-Requested-With"=> "XMLHttpRequest"})
      WotApi::Base.clans_accounts(clan_id: "12345")
    end

    it "returns parsed JSON" do
      allow(WotApi::Wrapper).to receive(:wot_web_get).and_return({items: [1,2,3]}.to_json)
      expect(WotApi::Base.clans_accounts(clan_id: "12345")).to eq [1,2,3]
    end
  end

end
