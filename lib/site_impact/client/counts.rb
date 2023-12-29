# frozen_string_literal: true

module SiteImpact
  module Client
    class Counts < Base

      def initialize(**params)
        @auth_token = nil
        super(base_url: SiteImpact.counts_base_url)
        authenticate
      end

      private

      def api_headers
        return { 'Content-Type' => 'application/json' } unless @auth_token
        {
          'User-Agent' => 'Ruby',
          'Content-Type' => 'application/json',
          'Authorization' => "Bearer #{@auth_token}"
        }
      end

      def authenticate
        response = post('/oauth/token',
                        {
                          username: SiteImpact.counts_username,
                          password: SiteImpact.counts_password,
                          grant_type: 'password',
                          client_id: SiteImpact.counts_client_id,
                          client_secret: SiteImpact.counts_client_secret
                        })
        @auth_token = response[:access_token]
      end

    end
  end
end
