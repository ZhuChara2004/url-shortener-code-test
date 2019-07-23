require File.expand_path('boot.rb', __dir__)

run Rack::URLMap.new '/' => RootRackApp.new
