# frozen_string_literal: true

require "rest-client"
require "base64"
require "cgi"
require "uri"

module SiteImpact
  module Client
    class Base

      def initialize(base_url:, **params)
        @base_url = base_url.chomp("/")
      end

      def execute(method:, endpoint:, payload: {}, headers: nil)
        response = nil
        headers = headers || api_headers
        headers[:params] = payload[:params] if payload.include? :params
        url = "#{@base_url}/#{endpoint.delete_prefix('/')}"
        request_options = {method: method,
                           url: url,
                           headers: headers,
                           read_timeout: SiteImpact.config.read_timeout,
                           open_timeout: SiteImpact.config.open_timeout}
        if [:post, :put].include? method
          payload.delete :params
          request_options[:payload] = payload.to_json
        end
        puts "SiteImpact -- URL: #{url}, Request: #{request_options.inspect}" if SiteImpact.config.debug

        begin
          response = ::RestClient::Request.execute(request_options)
        rescue ::RestClient::ExceptionWithResponse => e
          raise SiteImpact::ConnectionError.new(e.message, self)
        end

        body = JSON.parse(response, symbolize_names: true)
        puts "SiteImpact -- Response: #{body.inspect}" if SiteImpact.config.debug

        # TODO: Create consistent response objects for each API
        if body.is_a?(Hash) && body.has_key?(:success) && body[:success] == false
          message = "Unable to #{method.to_s.upcase} to endpoint: #{endpoint}. #{body[:errors]}"
          raise SiteImpact::ConnectionError.new(message, self)
        end

        body
      end

      def get(endpoint, params = {})
        payload = {params: params}
        execute(method: :get, endpoint: endpoint, payload: payload)
      end

      def post(endpoint, payload = {})
        execute(method: :post, endpoint: endpoint, payload: payload)
      end

      def put(endpoint, payload = {})
        execute(method: :put, endpoint: endpoint, payload: payload)
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
