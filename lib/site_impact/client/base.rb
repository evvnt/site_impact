# frozen_string_literal: true

require "httparty"
require "base64"
require "cgi"
require "uri"

module SiteImpact
  module Client
    class Base
      include HTTParty
      debug_output SiteImpact.config.debug ? $stdout : $stderr
      read_timeout SiteImpact.config.read_timeout
      open_timeout SiteImpact.config.open_timeout

      def initialize(base_url:, **params)
        @base_url = base_url.chomp("/")
      end

      def execute(method:, endpoint:, query: nil, body: nil, headers: nil)
        headers ||= api_headers
        url = "#{@base_url}/#{endpoint.delete_prefix('/')}"
        options = {body: body&.to_json, query: query, headers: headers}.compact

        puts "SiteImpact -- Request: URL: #{url}, Payload: #{options.inspect}" if SiteImpact.config.debug

        begin
          response = HTTParty.public_send(method, url, options)
        rescue => e
          raise SiteImpact::ConnetionError, e.message
        end
        puts response
        body = JSON.parse(response, symbolize_names: true)
        puts "SiteImpact -- Response: #{body.inspect}" if SiteImpact.config.debug

        unless success?(body)
          message = body.fetch(:message){ "Unable to complete Site Impact request." }
          raise SiteImpact::Error.new(message, body[:errors], body)
        end

        body
      end

      def success?(body)
        !body.nil?
      end

      def get(endpoint, params = {})
        execute(method: :get, endpoint: endpoint, query: params)
      end

      def post(endpoint, payload = {})
        execute(method: :post, endpoint: endpoint, body: payload)
      end

      def put(endpoint, payload = {})
        execute(method: :put, endpoint: endpoint, body: payload)
      end

      def delete(endpoint)
        execute(method: :delete, endpoint: endpoint)
      end

      private

      def api_headers
        raise NotImplementedError, 'Provide header method in child class'
      end
    end
  end
end
