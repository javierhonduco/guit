require_relative './test_helper'
# TODO: reduce requires duplication
require 'sinatra/base'
require 'rugged'
require './config'
require './helpers'
require './git_helpers'
require './model'
require './app'
require 'rack/test'

class TestHelpers < Minitest::Test
  include Rack::Test::Methods

  def app
    Guit
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
