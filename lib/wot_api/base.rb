# WotApi::Base wrapper for WotApi for compatibility, moved all real functionality directly to WotApi module
# This need never change - any future methods added do not need to be added here
module WotApi

  class Base

    def self.config(params={})
      WotApi.config(params)
    end

    def self.method_missing(method_sym, *params, &block)
      WotApi.method_missing(method_sym, *params, &block)
    end

    def self.respond_to?(method_sym, include_private = false)
      WotApi.respond_to?(method_sym, include_private)
    end

    def self.clans_accounts(params={})
      WotApi.clans_accounts(params)
    end

  end

end
