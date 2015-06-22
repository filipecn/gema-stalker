require 'rubygems'
require 'bundler'

Bundler.require

require './stalker.rb'
run Sinatra::Application
