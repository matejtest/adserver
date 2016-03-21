require 'rubygems'
require 'sinatra'
require 'adserver'

set :environment, :production
#Optionally set other variables here like :root or :views

run Sinatra.application