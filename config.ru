require 'rubygems'
require 'bundler/setup'
require 'sass/plugin/rack'

Sass::Plugin.options[:style] = :compressed		
use Sass::Plugin::Rack

require 'users'
require 'quotes'

Bundler.require

Dir.glob('./helpers/*.rb') { |f| require f }
require './quotes_app'

enable :sessions
set :session_secret, 'not the real secret'

ENV['DATABASE_URL'] = 'mysql2://dax:dax@localhost/quotes_production'

run QuotesApp
