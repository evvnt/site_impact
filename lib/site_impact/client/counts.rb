# frozen_string_literal: true

module SiteImpact
  module Client
    class Counts < Base
      # Refresh this many seconds before the token's reported expiry, so a request in flight
      # doesn't cross the expiry boundary and get rejected mid-poll.
      TOKEN_REFRESH_BUFFER = 10

      # A caller-supplied `auth_token` (e.g. one generated in the Counts System dashboard) is used
      # as-is and skips the initial OAuth handshake. We don't track an expiry for it — these
      # clients are short-lived (a single job run), so a proactive TTL-based refresh would never
      # trigger in practice. If it's actually invalid/expired, the reactive 401/403 handling in
      # Base#execute (see #reauthenticate!) falls back to a real OAuth handshake on first use.
      def initialize(auth_token: nil, **params)
        @auth_token = auth_token
        @token_expires_at = nil
        super(base_url: SiteImpact.counts_base_url)
        authenticate unless @auth_token
      end

      private

      def api_headers
        authenticate if @auth_token && token_expired?
        return { 'Content-Type' => 'application/json' } unless @auth_token
        {
          'User-Agent' => 'Ruby',
          'Content-Type' => 'application/json',
          'Authorization' => "Bearer #{@auth_token}"
        }
      end

      def reauthenticate!
        authenticate
        true
      rescue SiteImpact::Error, SiteImpact::ConnectionError
        false
      end

      def token_expired?
        @token_expires_at && Time.now >= @token_expires_at
      end

      # Explicit `headers:` bypasses `api_headers` so this never recurses back into itself while
      # a token is expired/being replaced. `allow_reauth: false` means a 401 here (bad
      # credentials) surfaces as a real error instead of retrying forever.
      def authenticate
        response = post('/oauth/token',
                        {
                          username: SiteImpact.counts_username,
                          password: SiteImpact.counts_password,
                          grant_type: 'password',
                          client_id: SiteImpact.counts_client_id,
                          client_secret: SiteImpact.counts_client_secret
                        },
                        headers: { 'Content-Type' => 'application/json' },
                        allow_reauth: false)
        @auth_token = response[:access_token]
        @token_expires_at = response[:expires_in] ? Time.now + response[:expires_in].to_i - TOKEN_REFRESH_BUFFER : nil
      end

    end
  end
end
