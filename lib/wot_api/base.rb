require "httparty"

module WotApi

  class Base
    include HTTParty
    base_uri 'https://api.worldoftanks.com'

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

    class << self
      attr_reader :application_id

      def application_id=(id)
        @application_id = id
        #self.default_params application_id: @application_id
      end

      def pathname(path)
        path.gsub(/(\/)+$/,'').gsub('/wot/','').gsub('/', '_')
      end

      def merged_params(params)
        params.merge({application_id: @application_id})
      end

      ENDPOINTS.each do |endpoint|
        define_method WotApi::Base.pathname(endpoint) do |params = {}|
          response = WotApi::Base.post(endpoint, body: merged_params(params))
          if response && response['data']
            response['data']
          else
            nil
          end
        end
      end
    end
  end

end
