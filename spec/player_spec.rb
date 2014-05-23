require 'spec_helper'

describe WotApi::Player do
  context "with a presumably valid application_id" do
    before(:all) { WotApi::Base.application_id = '12345'; puts WotApi::Base.application_id }

    it "inherits application_id from base" do
      puts WotApi::Base.application_id
      expect(WotApi::Player.default_params[:application_id]).to eq '12345'
    end
  end

  context "with no application_id" do
    before(:all) { WotApi::Base.application_id = nil; puts WotApi::Base.application_id }

    it "throws an exception when attempting to initialize an instance" do
      puts WotApi::Base.application_id
      expect{ WotApi::Player.new }.to raise_error
    end

    it "has a nil application_id" do
      expect(WotApi::Player.default_params[:application_id]).to be_nil
    end
  end

  it "gets latest application_id from Base when it becomes updated" do
    WotApi::Base.application_id = 'aaaaa'
    expect(WotApi::Player.default_params[:application_id]).to eq 'aaaaa'
    WotApi::Base.application_id = '54321'
    expect(WotApi::Player.default_params[:application_id]).to eq '54321'
  end
end
