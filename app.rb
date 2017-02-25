require 'dwolla_v2'
require 'dotenv'
Dotenv.load

app_key = ENV['APP_KEY']
app_secret = ENV['APP_SECRET']

$dwolla = DwollaV2::Client.new(key: app_key, secret: app_secret) do |config|
  config.environment = :sandbox # optional - defaults to production
end

p app_token = $dwolla.auths.client
