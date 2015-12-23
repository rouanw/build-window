require 'rspec'
require 'webmock/rspec'
require 'uri'

def require_job path
  require File.expand_path '../../jobs/' + path, __FILE__
end

RSpec.configure do |config|
  config.color = true
  config.order = 'random'
end
