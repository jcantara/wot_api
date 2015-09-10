require 'spec_helper'

describe WotApi do

  describe ".config" do
    context "with a valid config" do
      it "writes valid configuration to WotApi::Wrapper.configuration" do
        WotApi.config({'na' => '123456'})
        expect(WotApi::Wrapper.configuration).to eq({na: '123456'})
      end

      it "sets first item as default region" do
        WotApi.config({'na' => '123456'})
        expect(WotApi::Wrapper.default_region).to eq :na
        WotApi.config({'ru' => '444444','na' => '123456'})
        expect(WotApi::Wrapper.default_region).to eq :ru
      end
    end

    context "with an invalid config" do
      it "raises an error" do
        expect{WotApi.config({lalala: 'fake'})}.to raise_error WotApi::InvalidConfigError
      end
    end
  end

  describe ".method_missing" do
    it "checks WotApi::Wrapper for valid_endpoint" do
      expect(WotApi::Wrapper).to receive(:valid_endpoint?).with(:fake_method).and_return(true)
      allow(WotApi::Wrapper).to receive(:wot_api_post)
      WotApi.fake_method
    end

    context "valid_endpoint true" do
      before(:example) do
        allow(WotApi::Wrapper).to receive(:valid_endpoint?).with(:fake_method).and_return(true)
      end

      it "calls WotApi::Wrapper.wot_api_post" do
        expect(WotApi::Wrapper).to receive(:wot_api_post)
        WotApi.fake_method
      end

      context "with a two-part method name" do
        it "calls WotApi::Wrapper.wot_api_post with method symbol and parameters" do
          expect(WotApi::Wrapper).to receive(:wot_api_post).with(:fake_method, {hi: true})
          WotApi.fake_method(hi: true)
        end
      end

      context "with a three-part method name" do
        it "calls WotApi::Wrapper.wot_api_post with method symbol and parameters" do
          allow(WotApi::Wrapper).to receive(:valid_endpoint?).with(:quite_fake_method).and_return(true)
          expect(WotApi::Wrapper).to receive(:wot_api_post).with(:quite_fake_method, {hi: true})
          WotApi.quite_fake_method(hi: true)
        end
      end
    end

    context "valid_endpoint false" do
      before(:example) do
        allow(WotApi::Wrapper).to receive(:valid_endpoint?).with(:fake_method).and_return(false)
      end

      it "raises NoMethodError" do
        expect{ WotApi.fake_method(stuff: true) }.to raise_error NoMethodError
      end
    end
  end

  describe ".respond_to?" do
    it "checks WotApi::Wrapper for valid_endpoint" do
      expect(WotApi::Wrapper).to receive(:valid_endpoint?).with(:fake_method).and_return(true)
      WotApi.respond_to?(:fake_method)
    end

    context "valid_endpoint true" do
      before(:example) do
        allow(WotApi::Wrapper).to receive(:valid_endpoint?).with(:fake_method).and_return(true)
      end

      it "returns true" do
        expect(WotApi.respond_to?(:fake_method)).to eq true
      end
    end

    context "valid_endpoint false" do
      before(:example) do
        allow(WotApi::Wrapper).to receive(:valid_endpoint?).with(:fake_method).and_return(false)
      end

      it "returns false" do
        expect(WotApi.respond_to?(:fake_method)).to eq false
      end
    end
  end

  describe ".clans_accounts" do
    it "raises WotApi::InvalidArguments if clan_id not in arguments" do
      expect{ WotApi.clans_accounts }.to raise_error WotApi::InvalidArguments
    end

    it "calls WotApi::Wrapper.wot_web_get with endpoint and clan_id" do
      expect(WotApi::Wrapper).to receive(:wot_web_get).with("/clans/12345/accounts", headers: {"X-Requested-With"=> "XMLHttpRequest"})
      WotApi.clans_accounts(clan_id: "12345")
    end

    it "returns parsed JSON" do
      allow(WotApi::Wrapper).to receive(:wot_web_get).and_return({items: [1,2,3]}.to_json)
      expect(WotApi.clans_accounts(clan_id: "12345")).to eq [1,2,3]
    end
  end

end
