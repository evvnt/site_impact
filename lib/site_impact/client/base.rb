# frozen_string_literal: true

require "httparty"
require "base64"
require "cgi"
require "uri"

module SiteImpact
  module Client
    class Base
      include HTTParty

      def initialize(base_url:, **params)
        @base_url = base_url.chomp("/")
      end

      def execute(method:, endpoint:, query: nil, body: nil, headers: nil, allow_reauth: true)
        request_headers = headers || api_headers
        url = "#{@base_url}/#{endpoint.delete_prefix('/')}"
        options = {body: body&.to_json,
                   query: query,
                   headers: request_headers,
                   open_timeout: SiteImpact.config.open_timeout,
                   read_timeout: SiteImpact.config.read_timeout,
                   debug_output: SiteImpact.config.debug ? $stdout : $stderr}.compact

        puts "SiteImpact -- Request: URL: #{url}, Payload: #{options.inspect}" if SiteImpact.config.debug

        begin
          response = HTTParty.public_send(method, url, options)
        rescue => e
          raise SiteImpact::ConnectionError, e.message
        end
        puts response

        # Reauthenticate and retry (once) if the client believes it holds a valid token but the
        # server disagrees (expired/revoked ahead of our own expiry tracking). `allow_reauth: false`
        # on the retry prevents looping forever against credentials that are actually invalid.
        if allow_reauth && unauthenticated?(response) && reauthenticate!
          return execute(method: method, endpoint: endpoint, query: query, body: body, headers: nil, allow_reauth: false)
        end

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

      def post(endpoint, payload = {}, headers: nil, allow_reauth: true)
        execute(method: :post, endpoint: endpoint, body: payload, headers: headers, allow_reauth: allow_reauth)
      end

      def put(endpoint, payload = {})
        execute(method: :put, endpoint: endpoint, body: payload)
      end

      def patch(endpoint, payload = {})
        execute(method: :patch, endpoint: endpoint, body: payload)
      end

      def delete(endpoint)
        execute(method: :delete, endpoint: endpoint)
      end

      private

      # Auth-capable clients (see Client::Counts) override this to detect the shape of an
      # unauthenticated response and #reauthenticate! to act on it. Clients with no concept of an
      # expiring token (e.g. Client::Orders, which sends a static api-key) leave these as no-ops.
      def unauthenticated?(response)
        response.code == 401
      end

      def reauthenticate!
        false
      end

      def api_headers
        raise NotImplementedError, 'Provide header method in child class'
      end
    end
  end
end
