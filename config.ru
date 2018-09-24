require './app/web/web.rb'

run Rack::URLMap.new '/' => Web.new(':memory:')