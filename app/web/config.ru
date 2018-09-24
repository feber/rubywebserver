require '../../lib/web.rb'

run Rack::URLMap.new '/' => Web.new(':memory:')