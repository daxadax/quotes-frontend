require 'rubygems'
require 'bundler/setup'

require 'users'
require 'quotes'
require 'sass/plugin/rack'

Sass::Plugin.options[:style] = :compressed
use Sass::Plugin::Rack

Bundler.require

require './quotes_app'

ENV['DATABASE_URL'] = 'mysql2://dax:dax@localhost/quotes_dev'

run QuotesApp