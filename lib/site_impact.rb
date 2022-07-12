# frozen_string_literal: true

require "rbconfig"
require "forwardable"

require "site_impact/version"
require "site_impact/configuration"
require "site_impact/clients"
require "site_impact/resources"

module SiteImpact
  @config = SiteImpact::Configuration.setup

  class << self
    extend Forwardable

    attr_reader :config

    # Configurable options
    def_delegators :@config, :orders_api_key, :orders_api_key=
    def_delegators :@config, :orders_base_url, :orders_base_url=
    def_delegators :@config, :orders_test_seeds, :orders_test_seeds=
    def_delegators :@config, :orders_live_seeds, :orders_live_seeds=
    def_delegators :@config, :orders_tracking_login_id, :orders_tracking_login_id=
    def_delegators :@config, :orders_from_address_id, :orders_from_address_id=
    def_delegators :@config, :orders_image_host_id, :orders_image_host_id=
    def_delegators :@config, :orders_test_tracking_link_id, :orders_test_tracking_link_id=
    def_delegators :@config, :orders_opt_out_id, :orders_opt_out_id=

    def_delegators :@config, :counts_api_key, :counts_api_key=
    def_delegators :@config, :counts_base_url, :counts_base_url=
    def_delegators :@config, :counts_username, :counts_username=
    def_delegators :@config, :counts_password, :counts_password=
    def_delegators :@config, :counts_client_id, :counts_client_id=
    def_delegators :@config, :counts_client_secret, :counts_client_secret=

    def_delegators :@config, :reports_api_key, :reports_api_key=
    def_delegators :@config, :reports_base_url, :reports_base_url=

    def_delegators :@config, :debug, :debug=

  end

  class Error < StandardError; end

  class ConnectionError < StandardError
    attr_reader :response
    def initialize(message, response)
      super(message)
      @response = response
    end
  end

end
