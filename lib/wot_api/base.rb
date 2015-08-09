require "httparty"

module WotApi

  class Base
    include HTTParty

    REGIONS = {
      na: 'https://api.worldoftanks.com',
      ru: 'https://api.worldoftanks.ru',
      eu: 'https://api.worldoftanks.eu',
      asia: 'https://api.worldoftanks.asia',
      kr: 'https://api.worldoftanks.kr'
    }

    REGIONS_WEB = {
      na: 'http://na.wargaming.net',
      ru: 'http://ru.wargaming.net',
      eu: 'http://eu.wargaming.net',
      asia: 'http://asia.wargaming.net',
      kr: 'http://kr.wargaming.net',
    }

    class << self

      def config(params={})
        @configuration = {}
        @default_region = nil
        params.each do |region, id|
          region = region.to_sym
          if REGIONS[region] && id
            @default_region ||= region
            @configuration[region] = id.to_s
          else
            raise WotApi::InvalidConfigError, "Region: #{region} or ID: #{id} is invalid"
          end
        end
      end

      def clans_accounts(params={})
        raise WotApi::InvalidArguments, ":clan_id required" unless params[:clan_id]
        region = params.delete(:region).to_sym rescue nil
        set_base_uri(region, true)
        response = WotApi::Base.get("/clans/#{params[:clan_id]}/accounts", headers: {"X-Requested-With"=> "XMLHttpRequest"})
        JSON.parse(response||"{}")['items']
      end

      def method_missing(method_sym, *params, &block)
        if valid_endpoint(method_sym)
          return wot_api_post(method_sym, params)
        else
          super
        end
      end

      def respond_to?(method_sym, include_private = false)
        if valid_endpoint(method_sym)
          return true
        else
          super
        end
      end

      private

      def merged_params(params, region)
        application_id = get_application_id_for_region(region)
        raise WotApi::InvalidRegionError, "Invalid region specified: #{region}" unless application_id
        params.merge({application_id: application_id})
      end

      def get_application_id_for_region(region)
        raise WotApi::InvalidConfigError unless @configuration.class == Hash
        return @configuration[region]
      end

      def merged_post(endpoint, region, params={})
        WotApi::Base.post(endpoint, body: merged_params(params, region))
      end

      def set_base_uri(region, web=false)
        base_uri = web ? get_web_base_uri_for_region(region) : get_base_uri_for_region(region)
        raise WotApi::InvalidRegionError unless base_uri
        self.base_uri base_uri
      end

      def get_web_base_uri_for_region(region)
        return REGIONS_WEB[region] if region
        return REGIONS_WEB[get_default_region]
      end

      def get_base_uri_for_region(region)
        return REGIONS[region] if region
        return REGIONS[get_default_region]
      end

      def get_default_region
        raise WotApi::InvalidConfigError unless @default_region
        return @default_region
      end

      def wot_api_post(method_sym, params)
        endpoint = "/wot/" + method_sym.to_s.gsub('_','/') + "/"
        begin
          region = params.delete(:region).to_sym rescue nil
          set_base_uri(region)
          response = merged_post(endpoint, region, params.first)
        rescue
          raise WotApi::ConnectionError, "Could not connect to WoT endpoint #{endpoint}"
        end
        return format_response(response)
      end

      def format_response(response)
        if response && response['data']
          return response['data']
        end
        message = 'Unknown Error'
        message = response['error']['message'] if response && response['error'] && response['error']['message']
        raise WotApi::ResponseError, "WoT API response error: #{message}"
      end

      def valid_endpoint(method_sym)
        !self.methods.include?(method_sym) && method_sym.to_s =~ /^([^_]*)_([^_]*)$/
      end

    end
  end

end
