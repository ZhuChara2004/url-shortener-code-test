require File.expand_path('../boot.rb', __FILE__ )

run Rack::URLMap.new  "/" => RootRackApp.new
