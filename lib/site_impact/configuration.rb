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

    #Reports
    attr_accessor :reports_base_url
    attr_accessor :reports_api_key

    attr_reader :max_network_retries
    attr_reader :initial_network_retry_delay
    attr_reader :max_network_retry_delay
    attr_reader :open_timeout
    attr_reader :read_timeout
    attr_reader :write_timeout

    def self.setup
      new.tap do |instance|
        yield(instance) if block_given?
      end
    end


    def initialize
      @max_network_retries = 0
      @initial_network_retry_delay = 0.5
      @max_network_retry_delay = 2

      @open_timeout = 30
      @read_timeout = 80
      @write_timeout = 30

      @orders_base_url = 'https://oms.siteimpact.com/api/v2/'
      @counts_base_url = 'https://counts.siteimpact.com/'
      @reports_base_url = 'http://ecampaignstats.com/cp/index.php/report_api?WSDL'
    end

    # TODO: May not use these config items?
    def max_network_retries=(val)
      @max_network_retries = val.to_i
    end

    def max_network_retry_delay=(val)
      @max_network_retry_delay = val.to_i
    end

    def initial_network_retry_delay=(val)
      @initial_network_retry_delay = val.to_i
    end

    def open_timeout=(open_timeout)
      @open_timeout = open_timeout
    end

    def read_timeout=(read_timeout)
      @read_timeout = read_timeout
    end

    def write_timeout=(write_timeout)
      unless Net::HTTP.instance_methods.include?(:write_timeout=)
        raise NotImplementedError
      end

      @write_timeout = write_timeout
    end
  end

end
