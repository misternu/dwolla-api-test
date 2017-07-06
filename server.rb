require 'dwolla_v2'
require 'sinatra'
require 'dotenv'
require 'json'
require 'pp'
Dotenv.load

app_key = ENV['APP_KEY']
app_secret = ENV['APP_SECRET']

configure do
  set :public_folder, File.dirname(__FILE__) + '/public'
end

$dwolla = DwollaV2::Client.new(key: app_key, secret: app_secret) do |config|
  config.environment = :sandbox
end

get '/' do
  token = $dwolla.auths.client
  customers_response = token.get("customers", limit: 20)["_embedded"]['customers']
  customers = customers_response.map do |customer_data|
    first_name = customer_data.fetch('firstName', 'Firstname')
    last_name = customer_data.fetch('lastName', 'Lastname')
    email = customer_data.fetch('email', 'email')
    status = customer_data.fetch('status', 'status')
    "Name: #{first_name} #{last_name} Email:#{email} Status: #{status}"
  end
  customers = customers.map do |customer|
    "<div>#{customer}</div>"
  end .join
  erb :index, locals: {customers: customers}
end

post '/customers' do
  customer = {
    firstName: params[:first_name],
    lastName: params[:last_name],
    email: params[:email],
    ipAddress: params[:ip_address]
  }
  p customer
  redirect to('/')
end
