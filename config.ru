require 'rubygems'
require 'bundler/setup'
require 'sass/plugin/rack'

Sass::Plugin.options[:style] = :compressed
use Sass::Plugin::Rack
Bundler.require

require 'users'
require 'quotes'

Dir.glob('./helpers/*.rb') { |f| require f }
require './quotes_app'

enable :sessions
set :session_secret, ENV['SESSION_KEY'] || 'a not so secret key'

ENV['DATABASE_URL'] = 'mysql2://dax:dax@localhost/quotes_production'

run QuotesApp
