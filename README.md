# WotApi

API wrapper for World of Tanks in Ruby

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

    WotApi::Base.config({na: '123456'})

The available regions are: :na, :ru, :eu, :asia, :kr

The first region specified becomes the default if no region is specified in endpoint method arguments.

If using Rails, it is recommended to create an initializer that looks something like:

    WotApi::Base.config(YAML.load_file("#{::Rails.root}/config/wot_api.yml"))

Along with a yaml file, config/wot_api.yml:

    na: 123456
    ru: 6asdf6

Call endpoints like such:

    WotApi::Base.account_list(search: 'tank', region: :ru)

Will return an array or hash with the results, or throw an error with a message on a failure.

## Future plans

Add class wrappers for endpoints with convenience methods for class relationships and such. 

## Contributing

1. Fork it ( https://github.com/jcantara/wot_api/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
