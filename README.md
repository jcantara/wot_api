# DEPRECATED - WotApi

Deprecating because it's quite out of date, Dependabot is unhappy with the state of things, and I don't play WoT anymore. If you are going to use this it very likely needs a bit of updating/cleaning. 

API wrapper for World of Tanks in Ruby

[![No Maintenance Intended](http://unmaintained.tech/badge.svg)](http://unmaintained.tech/)

[![Build Status](https://travis-ci.org/jcantara/wot_api.svg?branch=master)](https://travis-ci.org/jcantara/wot_api)

[![Coverage Status](https://coveralls.io/repos/jcantara/wot_api/badge.png)](https://coveralls.io/r/jcantara/wot_api)

## Installation

Add this line to your application's Gemfile:

    gem 'wot_api'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install wot_api

## Usage

Get an Application ID from Wargaming and read the available endpoints here: https://na.wargaming.net/developers/

NOTE: Other WoT geographical regions require different Application IDs

Initialize the gem with your Application ID(s):

    WotApi.config({na: '123456'})

The available regions are: :na, :ru, :eu, :asia, :kr

The first region specified becomes the default if no region is specified in endpoint method arguments.

If using Rails, it is recommended to create an initializer that looks something like:

    WotApi.config(YAML.load_file("#{::Rails.root}/config/wot_api.yml"))

Along with a yaml file, config/wot_api.yml:

    na: 123456
    ru: 6asdf6

Call endpoints like such:

    WotApi.account_list(search: 'tank', region: :ru)

Which wraps the '/wot/account/list' endpoint, with 'search' params and in the :ru region

Will return an array or hash with the results, or throw an error with a message on a failure.

For endpoints that do not start with '/wot/' you can use a method like such:

    WotApi.wgn_clans_list(search: 'bananas')

to use /wgn/clans/list instead of /wot/clans/list

NOTE: Version 1.2.0 removes the need for all api methods to be called with "WotApi::Base.method", instead can just use "WotApi.method" for less keystrokes. However, the existing methods are still available at WotApi::Base for compatibility. 

## Clan member resources

There is an additional endpoint used to list clan member resource counts:

    WotApi.clans_accounts(clan_id: "12345")

This will return an array of the clan members with their recent and total resource counts

## Contributing

1. Fork it ( https://github.com/jcantara/wot_api/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
