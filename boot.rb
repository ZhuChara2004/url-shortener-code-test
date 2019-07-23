require 'bundler/setup'
Bundler.require :default

require_relative 'lib/link_storage'

class RootRackApp
  STATUS_OK = 200
  STATUS_CREATED = 201
  STATUS_REDIRECT = 302
  STATUS_NOT_FOUND = 404
  STATUS_UNPROCESSABLE_ENTITY = 422
  ROOT_PATH = '/'

  def initialize
    @storage = storage(ENV['RACK_ENV'])
  end

  def call(env)
    request = Rack::Request.new(env)

    return unprocessable_entity_response unless request.post? || request.get?

    if request.post?
      url = JSON.parse(request.body.read)['url']
      return [STATUS_CREATED, response_headers, shorten_url(url, request)]
    end

    return [STATUS_OK, response_headers, index_data_body] if request.path == ROOT_PATH

    expanded_url = expand_url(request.path[1..-1])
    case expanded_url
    when ''
      [STATUS_NOT_FOUND, response_headers, not_found_body]
    else
      [STATUS_REDIRECT, redirect_headers(expanded_url), []]
    end
  end

  private

  def storage(env)
    LinkStorage.new("#{env}_url_store.pstore")
  end

  def response_headers
    { "Content-Type" => "application/json" }
  end

  def redirect_headers(url)
    { "Location" => url }
  end

  def index_data_body
    [@storage.index.to_json]
  end

  def not_found_body
    [{ error: 'not found' }.to_json]
  end

  def unprocessable_entity_body
    [{ error: 'unprocessable entity' }.to_json]
  end

  def shorten_url(url, request)
    [{ short_url: "#{request.url}#{@storage.save_value(url)}",  }.to_json]
  end

  def expand_url(shortened_url)
    @storage.read_value(shortened_url)
  end

  def unprocessable_entity_response
    [STATUS_UNPROCESSABLE_ENTITY, response_headers, unprocessable_entity_body]
  end
end
