
require 'rubygems'
require 'sinatra'
require 'data_mapper'
require './lib/authorization'

#require all ".rb" files from "models" directory
Dir["./models/*.rb"].each {|file| require file }

#create "adserver.db" sqlite3 database
DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/adserver.db")


configure :development do
	#Create or upgrade all tables at once (will be run only on development mode)
	DataMapper.auto_upgrade!
end

#we use helpers to include namespaces we want to use in our sinatra app
helpers do
	include Sinatra::Authorization
end

#set utf-8 for outgoing
#it is run before every handler
before do
	headers "Content-Type" => "text/html; charset=utf-8"
end

get '/' do
	@title = "Welcome to sinatra app"
	erb :welcome
end


get '/ad' do
	id = repository(:default).adapter.query("SELECT id FROM ads ORDER BY random() LIMIT 1;")
	@ad = Ad.get(id)
	erb :ad, :layout => false
end


get '/list' do
	require_admin

	@title = "List Ads"
	@ads = Ad.all(:order => [:created_at.desc])
	erb :list
end


get '/new' do
	require_admin
	@title = "Create a new ad"
	erb :new
end


post '/create' do
	require_admin

	@ad = Ad.new(params[:ad])

	if @ad.save
		@ad.handle_upload(params[:image])
		redirect "/show/#{@ad.id}"
	else
		redirect "/list"
	end
end


get '/delete/:id' do
	require_admin

	ad = Ad.get(params[:id])

	unless ad.nil?
		path = File.join(Dir.pwd, "/public/ads", ad.filename)
		File.delete(path)
		ad.clicks.destroy
		ad.destroy
	end

	redirect('/list')
end

get '/show/:id' do
	require_admin

	@ad = Ad.get(params[:id])

	if @ad
		erb :show
	else
		redirect("/list")
	end
end


get '/click/:id' do

	ad = Ad.get(params[:id])
	ad.clicks.create(:ip_address => env["REMOTE_ADDR"])

	#if "ad.url" doesn't contain "http://" string, Sinatra will append "http://localhost:9393" before "url" value...
	redirect(ad.url)

end