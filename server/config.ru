require 'rubygems'
require 'bundler/setup'
require 'sinatra'
require 'rack'
require 'haml'
require File.dirname(__FILE__)+'/main'

set :environemt, :production

run Sinatra::Application
