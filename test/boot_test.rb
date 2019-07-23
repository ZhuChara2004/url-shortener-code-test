# frozen_string_literal: true

require File.expand_path 'test_helper', __dir__

class RootRackAppTest < MiniTest::Test
  include Rack::Test
  include Rack::Test::Methods

  def app
    Rack::Builder.parse_file('config.ru').first
  end

  def test_index
    get('/')

    assert last_response.ok?
    assert JSON.parse(last_response.body).is_a? Hash
  end

  def test_post
    post('/', { url: 'foo.bar' }.to_json)

    assert last_response.created?
    response_body = JSON.parse(last_response.body)
    assert response_body.is_a? Hash
    assert response_body.keys.include?('short_url')
  end

  def test_not_found
    get '/asd'

    assert last_response.not_found?
  end

  def test_redirect
    get('/')
    full_url, short_url = JSON.parse(last_response.body).first

    get("/#{short_url}")
    assert last_response.redirect?
    assert last_response.location == full_url
  end
end
