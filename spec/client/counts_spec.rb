require "spec_helper"

RSpec.describe SiteImpact::Client::Counts do
  let(:base_url) { "https://counts.siteimpact.com" }

  # Deliberately not setting a JSON Content-Type header: the real Site Impact API doesn't
  # either, so HTTParty leaves the body unparsed and Client::Base#execute JSON-parses it itself.
  # Matching that here exercises the same `JSON.parse(response, ...)` path production hits.
  def stub_token(access_token:, expires_in: nil)
    body = {access_token: access_token}
    body[:expires_in] = expires_in if expires_in
    stub_request(:post, "#{base_url}/oauth/token").to_return(status: 200, body: body.to_json)
  end

  def stub_check(status: 200, body: {status: "Successful", count: 42})
    stub_request(:get, "#{base_url}/api/counts/count-1/check")
      .to_return(status: status, body: body.to_json)
  end

  before do
    SiteImpact.counts_base_url = base_url
    SiteImpact.counts_username = "user"
    SiteImpact.counts_password = "pass"
    SiteImpact.counts_client_id = "client-id"
    SiteImpact.counts_client_secret = "client-secret"
  end

  describe "#initialize" do
    it "authenticates once and sends the resulting token on subsequent requests" do
      stub_token(access_token: "token-1")
      stub_check

      client.get("/api/counts/count-1/check")

      expect(a_request(:post, "#{base_url}/oauth/token")).to have_been_made.once
      expect(a_request(:get, "#{base_url}/api/counts/count-1/check")
        .with(headers: {"Authorization" => "Bearer token-1"})).to have_been_made.once
    end
  end

  describe "reuse across multiple polls" do
    it "does not re-authenticate before the token expires" do
      stub_token(access_token: "token-1", expires_in: 3600)
      stub_check

      client.get("/api/counts/count-1/check")
      client.get("/api/counts/count-1/check")
      client.get("/api/counts/count-1/check")

      expect(a_request(:post, "#{base_url}/oauth/token")).to have_been_made.once
    end

    it "proactively re-authenticates once the token has expired" do
      now = Time.now
      allow(Time).to receive(:now).and_return(now)
      stub_token(access_token: "token-1", expires_in: 30)
      stub_check
      client

      allow(Time).to receive(:now).and_return(now + 25)
      stub_token(access_token: "token-2", expires_in: 30)
      client.get("/api/counts/count-1/check")

      expect(a_request(:get, "#{base_url}/api/counts/count-1/check")
        .with(headers: {"Authorization" => "Bearer token-2"})).to have_been_made.once
    end
  end

  describe "reactive re-authentication" do
    it "retries once with a fresh token when the server rejects the current one as unauthenticated" do
      stub_token(access_token: "token-1")
      client

      stub_request(:get, "#{base_url}/api/counts/count-1/check")
        .with(headers: {"Authorization" => "Bearer token-1"})
        .to_return(status: 401, body: {}.to_json)

      stub_token(access_token: "token-2")
      stub_request(:get, "#{base_url}/api/counts/count-1/check")
        .with(headers: {"Authorization" => "Bearer token-2"})
        .to_return(status: 200, body: {status: "Successful", count: 7}.to_json)

      resp = client.get("/api/counts/count-1/check")

      expect(resp[:count]).to eq(7)
      expect(a_request(:post, "#{base_url}/oauth/token")).to have_been_made.times(2)
    end

    it "retries at most once when the server keeps rejecting the token (e.g. bad credentials)" do
      stub_token(access_token: "token-1")
      client

      stub_request(:get, "#{base_url}/api/counts/count-1/check")
        .to_return(status: 401, body: {}.to_json)

      client.get("/api/counts/count-1/check")

      expect(a_request(:post, "#{base_url}/oauth/token")).to have_been_made.times(2)
      expect(a_request(:get, "#{base_url}/api/counts/count-1/check")).to have_been_made.times(2)
    end
  end

  describe "with a caller-supplied auth_token" do
    it "uses the given token immediately without hitting the OAuth endpoint" do
      stub_check

      static_client = described_class.new(auth_token: "static-token")
      static_client.get("/api/counts/count-1/check")

      expect(a_request(:post, "#{base_url}/oauth/token")).not_to have_been_made
      expect(a_request(:get, "#{base_url}/api/counts/count-1/check")
        .with(headers: {"Authorization" => "Bearer static-token"})).to have_been_made.once
    end

    [401, 403].each do |status|
      it "falls back to OAuth if the static token is rejected with a #{status}" do
        static_client = described_class.new(auth_token: "static-token")

        stub_request(:get, "#{base_url}/api/counts/count-1/check")
          .with(headers: {"Authorization" => "Bearer static-token"})
          .to_return(status: status, body: {}.to_json)

        stub_token(access_token: "oauth-token")
        stub_request(:get, "#{base_url}/api/counts/count-1/check")
          .with(headers: {"Authorization" => "Bearer oauth-token"})
          .to_return(status: 200, body: {status: "Successful", count: 7}.to_json)

        resp = static_client.get("/api/counts/count-1/check")

        expect(resp[:count]).to eq(7)
        expect(a_request(:post, "#{base_url}/oauth/token")).to have_been_made.once
      end
    end

    it "never proactively re-authenticates, no matter how much time passes" do
      now = Time.now
      allow(Time).to receive(:now).and_return(now)
      static_client = described_class.new(auth_token: "static-token")
      stub_check

      allow(Time).to receive(:now).and_return(now + 86400)
      static_client.get("/api/counts/count-1/check")

      expect(a_request(:post, "#{base_url}/oauth/token")).not_to have_been_made
      expect(a_request(:get, "#{base_url}/api/counts/count-1/check")
        .with(headers: {"Authorization" => "Bearer static-token"})).to have_been_made.once
    end
  end

  def client
    @client ||= described_class.new
  end
end
