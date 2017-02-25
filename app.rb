require 'dwolla_v2'
require 'dotenv'
require 'json'
Dotenv.load

app_key = ENV['APP_KEY']
app_secret = ENV['APP_SECRET']

$dwolla = DwollaV2::Client.new(key: app_key, secret: app_secret) do |config|
  config.environment = :sandbox # optional - defaults to production
end

token = $dwolla.auths.client

# request_body = {
#   :firstName => 'Joe',
#   :lastName => 'Buyer',
#   :email => 'jbuyer@mail.net',
#   :ipAddress => '99.99.99.99'
# }

# new_customer = token.post "customers", request_body
# # p new_customer.headers[:location]

# customer_url = token.get("customers", limit: 10)["_embedded"]["customers"][0]["_links"]["self"]["href"]
# customer_url = "https://api-uat.dwolla.com/customers/8596a99d-2b7b-4f2a-9292-d7b26b3a2351"

# customer = token.post "#{customer_url}/iav-token"
# p customer.token

iav_token = "PXJsdPTbNR9510hHNRFfTuKbdip2clxxD2cyFJ7QBhkhDHXmMB"


