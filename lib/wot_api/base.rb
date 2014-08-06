require "httparty"

module WotApi

  class Base
    include HTTParty

    ENDPOINTS = [
      '/wot/account/list/',
      '/wot/account/info/',
      '/wot/account/tanks/',
      '/wot/account/achievements/',
      '/wot/clan/list/',
      '/wot/clan/info/',
      '/wot/clan/battles/',
      '/wot/clan/top/',
      '/wot/clan/provinces/',
      '/wot/clan/victorypointshistory/',
      '/wot/clan/membersinfo/',
      '/wot/globalwar/clans/',
      '/wot/globalwar/famepoints/',
      '/wot/globalwar/maps/',
      '/wot/globalwar/provinces/',
      '/wot/globalwar/top/',
      '/wot/globalwar/tournaments/',
      '/wot/encyclopedia/tanks/',
      '/wot/encyclopedia/tankinfo/',
      '/wot/encyclopedia/tankengines/',
      '/wot/encyclopedia/tankturrets/',
      '/wot/encyclopedia/tankradios/',
      '/wot/encyclopedia/tankchassis/',
      '/wot/encyclopedia/tankguns/',
      '/wot/encyclopedia/achievements/',
      '/wot/ratings/types/',
      '/wot/ratings/accounts/',
      '/wot/ratings/neighbors/',
      '/wot/ratings/top/',
      '/wot/ratings/dates/',
      '/wot/tanks/stats/',
      '/wot/tanks/achievements/'
    ]

    REGIONS = {
      na: 'https://api.worldoftanks.com',
      ru: 'https://api.worldoftanks.ru',
      eu: 'https://api.worldoftanks.eu',
      asia: 'https://api.worldoftanks.asia',
      kr: 'https://api.worldoftanks.kr'
    }

    class << self
      attr_reader :configuration
      attr_reader :default_region

      def config(params={})
        @configuration = {}
        @default_region = nil
        params.each do |conf|
          region = conf[0].to_sym
          application_id = conf[1]
          if REGIONS[region] && application_id
            @default_region ||= region
            @configuration[region] = {base_uri: REGIONS[region], application_id: application_id.to_s}
          else
            raise WotApi::InvalidConfigError
          end
        end
      end

      def pathname(path)
        path.gsub(/(\/)+$/,'').gsub('/wot/','').gsub('/', '_')
      end

      def merged_params(params)
        raise WotApi::InvalidConfigError unless @configuration.class == Hash
        if region = params.delete(:region).to_sym rescue nil
          config = @configuration[region]
        else
          config = @configuration[@default_region]
        end
        base_uri = config[:base_uri]
        application_id = config[:application_id]
        raise WotApi::InvalidRegionError unless base_uri && application_id
        self.base_uri base_uri
        params.merge({application_id: application_id})
      end

      ENDPOINTS.each do |endpoint|
        define_method WotApi::Base.pathname(endpoint) do |params = {}|
          begin
            response = WotApi::Base.post(endpoint, body: merged_params(params))
          rescue
            raise
          end
          if response && response['data']
            return response['data']
          else
            message = 'Unknown Error'
            message = response['error']['message'] if response && response['error'] && response['error']['message']
            raise WotApi::ResponseError, message
          end
        end
      end
    end
  end

end
