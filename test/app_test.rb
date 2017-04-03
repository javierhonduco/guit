require_relative './test_helper'
require 'rack/test'
require 'sinatra/base'
require 'rugged'
# TODO: reduce requires duplication
require './config'
require './app'
require './helpers/helpers'
require './models/repo'

class TestHelpers < Minitest::Test
  include Rack::Test::Methods

  def app
    Guit::App
  end

  def test_ultra_super_mega_basic
    get '/favicon.ico'
    assert 404, last_response.status
  end

  def test_ultra_super_mega_basic_2
    get '/'
    assert 200, last_response.status
  end
end
