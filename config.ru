require 'rubygems'
require 'bundler/setup'
require 'quotes'
require 'sass/plugin/rack'

Sass::Plugin.options[:style] = :compressed
use Sass::Plugin::Rack

Bundler.require

require './quotes_app'

run QuotesApp