# frozen_string_literal: true

require 'faraday'
require 'zerobounce/middleware/raise_http_exception'

module Zerobounce
  # Configuration object for Zerobounce.
  #
  # @author Aaron Frase
  #
  # @attr [String] host
  #   The Zerobounce API host.
  #
  # @attr [Hash] headers
  #   Headers to use in all requests.
  #
  # @attr [String] apikey
  #   A Zerobounce API key.
  #
  # @attr [Proc] middleware
  #   The middleware used by Faraday for each request.
  #
  #   @note If you modify the default make sure to add middleware to parse
  #     the response as json and symbolize the keys.
  #
  # @attr [String] api_version
  #   The version of the API to use.
  #
  # @attr [Array<Symbol>] valid_statues
  #   The statuses that are considered valid by {Response#valid?}.
  # @attr [Integer] timeout
  #   The max number of seconds to wait for the request to complete.
  class Configuration
    attr_accessor :host
    attr_accessor :headers
    attr_accessor :apikey
    attr_accessor :middleware
    attr_accessor :api_version
    attr_accessor :valid_statuses
    attr_accessor :timeout

    def initialize
      self.host = 'https://api.zerobounce.net'
      self.apikey = ENV.fetch('ZEROBOUNCE_API_KEY', nil)
      self.api_version = 'v2'
      self.valid_statuses = %i[valid catch_all]
      self.headers = { user_agent: "ZerobounceRubyGem/#{Zerobounce::VERSION}" }
      self.timeout = nil

      self.middleware = proc do |builder|
        builder.response(:json, content_type: /\bjson$/, parser_options: { symbolize_names: true })
        builder.response(:logger) { |l| l.filter(/(api_?key=)(\w+)/, '\1[REMOVED]') } if ENV['ZEROBOUNCE_API_DEBUG']
        builder.use(Zerobounce::Middleware::RaiseHttpException)
        builder.adapter(Faraday.default_adapter)
      end
    end
  end
end
