require 'simplecov'
SimpleCov.start do
  add_filter '/spec/'

  require 'bundler/setup'
  Bundler.setup

  require 'fakeweb'
  FakeWeb.allow_net_connect = false

  require 'wot_api'

  RSpec.configure do |config|
    config.treat_symbols_as_metadata_keys_with_true_values = true
    config.run_all_when_everything_filtered = true
    config.filter_run :focus

    config.order = 'random'
  end

end
