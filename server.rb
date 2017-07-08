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
  token = Token.fresh($dwolla)
  customers_response = token.get("customers", limit: 20)["_embedded"]['customers']
  customers = customers_response.map do |customer_data|
    {
      id: customer_data.fetch('id'),
      first_name: customer_data.fetch('firstName', 'Firstname'),
      last_name: customer_data.fetch('lastName', 'Lastname'),
      email: customer_data.fetch('email', 'email'),
      status: customer_data.fetch('status', 'status')
    }
  end
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

get '/customers/:id/iav-token' do
  token = Token.fresh($dwolla)
  request = 'https://api-uat.dwolla.com/customers/' + params[:id] + '/iav-token'
  p iav_token = token.post(request).token
end

get '/customers/:id' do
  token = Token.fresh($dwolla)
  url = 'https://api-uat.dwolla.com/customers/' + params[:id]
  customer = token.get(url)
  funding_sources = token.get(url+ '/funding-sources')['_embedded']['funding-sources']
  funding_sources.map! do |source|
    {
      id: source.fetch('id'),
      status: source.fetch('status'),
    }
  end
  data = {
    id: params[:id],
    first_name: customer.fetch('firstName'),
    last_name: customer.fetch('lastName'),
    email: customer.fetch('email'),
    status: customer.fetch('status')
  }
  erb :show, locals: {customer: data, funding_sources: funding_sources}
end
