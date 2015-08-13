require "httparty"

module WotApi

  def self.config(params={})
    WotApi::Wrapper.configuration = {}
    WotApi::Wrapper.default_region = nil
    params.each do |region, id|
      region = region.to_sym
      if WotApi::Wrapper::REGIONS[region] && id
        WotApi::Wrapper.default_region ||= region
        WotApi::Wrapper.configuration[region] = id.to_s
      else
        raise WotApi::InvalidConfigError, "Region: #{region} or ID: #{id} is invalid"
      end
    end
  end

  def self.method_missing(method_sym, *params, &block)
    if WotApi::Wrapper.valid_endpoint?(method_sym)
      return WotApi::Wrapper.wot_api_post(method_sym, params.first)
    else
      super
    end
  end

  def self.respond_to?(method_sym, include_private = false)
    if WotApi::Wrapper.valid_endpoint?(method_sym)
      return true
    else
      super
    end
  end

  # methods outside of 'typical' WoT API calls:

  def self.clans_accounts(params={})
    raise WotApi::InvalidArguments, ":clan_id required" unless params[:clan_id]
    response = WotApi::Wrapper.wot_web_get("/clans/#{params[:clan_id]}/accounts", headers: {"X-Requested-With"=> "XMLHttpRequest"})
    JSON.parse(response||"{}")['items']
  end

end
