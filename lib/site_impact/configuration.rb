# frozen_string_literal: true

module SiteImpact
  class Configuration
    # Orders
    attr_accessor :orders_api_key
    attr_accessor :orders_base_url
    attr_accessor :orders_test_seeds
    attr_accessor :orders_live_seeds
    attr_accessor :orders_tracking_login_id
    attr_accessor :orders_from_address_id
    attr_accessor :orders_image_host_id
    attr_accessor :orders_test_tracking_link_id
    attr_accessor :orders_opt_out_id

    # Counts
    attr_accessor :counts_api_key
    attr_accessor :counts_base_url
    attr_accessor :counts_username
    attr_accessor :counts_password
    attr_accessor :counts_client_id
    attr_accessor :counts_client_secret
    attr_accessor :counts_max_radius

    #Reports
    attr_accessor :reports_base_url
    attr_accessor :reports_api_key

    attr_reader :open_timeout
    attr_reader :read_timeout
    attr_accessor :debug


    def self.setup
      new.tap do |instance|
        yield(instance) if block_given?
      end
    end


    def initialize
      @open_timeout = 30
      @read_timeout = 80
      @debug = false

      @orders_base_url = 'https://oms.siteimpact.com/api/v2/'
      @counts_base_url = 'https://counts.siteimpact.com/'
      @reports_base_url = 'http://ecampaignstats.com/cp/index.php/report_api?WSDL'

      # Max radius around a zip supported by Site Impact
      @counts_max_radius = 200
    end


    def open_timeout=(open_timeout)
      @open_timeout = open_timeout
    end

    def read_timeout=(read_timeout)
      @read_timeout = read_timeout
    end

  end

end
