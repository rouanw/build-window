require 'dotenv'
Dotenv.load

require 'dashing'

configure do
  set :auth_token, 'YOUR_AUTH_TOKEN'

  helpers do
    def protected!
     # Put any authentication code you want in here.
     # This method is run before accessing any resource.
    end
  end
end

map Sinatra::Application.assets_prefix do
  run Sinatra::Application.sprockets
end

if Builds::BUILD_CONFIG['teamCityBaseUrl']
  require 'teamcity'
  TeamCity.configure do |config|
    config.endpoint = Builds::BUILD_CONFIG['teamCityBaseUrl'] + '/app/rest?guest=1'
  end
end

run Sinatra::Application
