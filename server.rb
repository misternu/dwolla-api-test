require 'dwolla_v2'
require 'sinatra'
require 'dotenv'
require 'json'
require 'pp'
require 'csv'
require_relative 'lib/token'
Dotenv.load

app_key = ENV['APP_KEY']
app_secret = ENV['APP_SECRET']
ROOT_DIR = File.dirname(__FILE__)

configure do
  set :public_folder, File.dirname(__FILE__) + '/public'
end

$dwolla = DwollaV2::Client.new(key: app_key, secret: app_secret) do |config|
  config.environment = :sandbox
end

Token.fresh($dwolla)

get '/' do
  p token = Token.fresh($dwolla)
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
  token = Token.fresh($dwolla)
  customer = {
    firstName: params[:first_name],
    lastName: params[:last_name],
    email: params[:email],
    ipAddress: params[:ip_address]
  }
  new_customer = token.post "customers", customer
  p new_customer
  redirect to('/')
end

get '/test' do
  p Token.fresh($dwolla)
  'running'
end
