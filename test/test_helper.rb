ENV['RACK_ENV'] = 'test'
require 'minitest/autorun'
require 'rack/test'
require 'rack-minitest'
require 'pry'

require_relative '../boot'
