require 'rubygems'
require 'bundler/setup'
require 'sass/plugin/rack'

Sass::Plugin.options[:style] = :compressed		
use Sass::Plugin::Rack

require 'users'
require 'quotes'

Bundler.require

require './quotes_app'

ENV['DATABASE_URL'] = 'mysql2://dax:dax@localhost/quotes_production'

run QuotesApp
