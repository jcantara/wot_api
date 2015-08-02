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
        params ||= {}
        raise WotApi::InvalidConfigError unless @configuration.class == Hash
        if region = params.delete(:region).to_sym rescue nil
          config = @configuration[region]
        else
          config = @configuration[@default_region]
        end
        base_uri = config[:base_uri] rescue nil
        application_id = config[:application_id] rescue nil
        raise WotApi::InvalidRegionError unless base_uri && application_id
        self.base_uri base_uri
        params.merge({application_id: application_id})
      end

      def merged_post(endpoint, params={})
        WotApi::Base.post(endpoint, body: merged_params(params))
      end

      def method_missing(method_sym, *arguments, &block)
        puts "METHOD MISSING: " + method_sym.to_s
        if !self.methods.include?(method_sym) && method_sym.to_s =~ /^([^_]*)_([^_]*)$/
          endpoint = "/wot/" + method_sym.to_s.gsub('_','/') + "/"
          begin
            response = merged_post(endpoint, arguments.first)
          rescue
            raise WotApi::ConnectionError
          end
          if response && response['data']
            return response['data']
          else
            message = 'Unknown Error'
            message = response['error']['message'] if response && response['error'] && response['error']['message']
            raise WotApi::ResponseError, message
          end
        else
          super
        end
      end
    end
  end

end
