# frozen_string_literal: true

require 'ostruct'
require 'savon'

module SiteImpact
  class Report
    class << self

      def get_client_report(from)
        results = client.get_client_report(from)
        results = results.dig(:get_client_report_response,
                                                     :get_client_report_result,
                                                     :ds,
                                                     :diffgram,
                                                     :new_data_set,
                                                     :table)
        [results].flatten.map do |result|
          OpenStruct.new(
            site_impact_order_id: result[:campaign_x0020_id].to_i,
            opens: result[:opens].to_i,
            clicks: result[:clicks].to_i,
            broadcast_time: result[:broadcast_x0020_date]
          )
        end
      end

      def get_link_report(campaign_id)
        client.get_link_report(campaign_id)
      end

      def get_link_report_summary(campaign_id)
        client.get_link_report_summary(campaign_id)
      end

      def operations
        client.operations
      end

      private

      def client
        SiteImpact::Client::Reports.new
      end

    end
  end
end
