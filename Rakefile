require "bundler/gem_tasks"

require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new('spec')

task :default => :spec

require 'yaml'
require 'wot_api'

namespace :wotapi do

  task :generate_api_fixtures, :endpoint do |t, args|
    endpoint = args[:endpoint] || 'all'
    STDOUT.puts "Please enter application_id:"
    application_id = STDIN.gets.chomp
    endpoints = YAML.load_file(File.join('spec', 'fixtures', 'endpoints.yml'))
    WotApi::Base::ENDPOINTS.select{|e| e == endpoint || endpoint == 'all' }.each do |path|
      pathname = WotApi::Base.pathname(path)
      data = endpoints[path].merge({application_id: application_id}).map{|k,v| "#{k}=#{v}"}.join('&')
      execute = "curl -is --data \"#{data}\" #{WotApi::Base.base_uri}#{path} > spec/fixtures/#{pathname}.json"
      STDOUT.puts execute
      STDOUT.puts `#{execute}`
    end
  end

end
