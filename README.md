# WotApi

API wrapper for World of Tanks

## Installation

Add this line to your application's Gemfile:

    gem 'wot_api'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install wot_api

## Usage

Get an Application ID from Wargaming and read the available endpoints here: https://na.wargaming.net/developers/

Initialize the gem with your Application ID:

WotApi::Base.application_id = '123456'

Call endpoints like such:

WotApi::Base.account_list(search: 'tank')

Will return an array or hash with the results, or nil on a failure.

## Future plans

Throw exceptions on failures

Add class wrappers for endpoints with convenience methods for class relationships and such. 

## Contributing

1. Fork it ( https://github.com/jcantara/wot_api/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
