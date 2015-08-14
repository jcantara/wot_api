require "httparty"

module WotApi

  class Wrapper
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

      attr_accessor :configuration, :default_region

      def wot_api_post(method_sym, params)
        params ||= {}
        endpoint = method_to_endpoint(method_sym)
        region = params.delete(:region).to_sym rescue get_default_region
        set_base_uri(region)
        begin
          response = merged_post(endpoint, region, params)
        rescue
          raise WotApi::ConnectionError, "Could not connect to WoT endpoint #{endpoint.to_s}"
        end
        return format_response(response)
      end

      def wot_web_get(endpoint, params)
        params ||= {}
        region = params.delete(:region).to_sym rescue get_default_region
        set_base_uri(region, true)
        begin
          return self.get(endpoint, params).parsed_response
        rescue Exception => e
          raise WotApi::ConnectionError, "ERROR with WoT web endpoint #{endpoint.to_s}"
        end
      end

      def valid_endpoint?(method_sym)
        !(method_sym.to_s =~ /^([^_]*)_([^_]*)$/).nil?
      end

      private

      def method_to_endpoint(method_sym)
        "/wot/" + method_sym.to_s.gsub('_','/') + "/"
      end

      def set_base_uri(region, web=false)
        base_uri = web ? get_web_base_uri_for_region(region) : get_base_uri_for_region(region)
        raise WotApi::InvalidRegionError unless base_uri
        self.base_uri base_uri
      end

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
        self.post(endpoint, body: merged_params(params, region))
      end

      def get_web_base_uri_for_region(region)
        return REGIONS_WEB[region]
      end

      def get_base_uri_for_region(region)
        return REGIONS[region]
      end

      def get_default_region
        raise WotApi::InvalidConfigError unless @default_region
        return @default_region
      end

      def format_response(response)
        if response && response['data']
          return response['data']
        end
        message = 'Unknown Error'
        message = response['error']['message'] if response && response['error'] && response['error']['message']
        raise WotApi::ResponseError, "WoT API response error: #{message}"
      end

    end
  end

end
