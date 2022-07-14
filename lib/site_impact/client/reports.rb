# frozen_string_literal: true

require 'savon'

module SiteImpact
  module Client
    class Reports

      def initialize(**params)
        @base_url = SiteImpact.reports_base_url
        @client = Savon.client(
          wsdl: @base_url,
          convert_request_keys_to: :none
        )
      end

      def operations
        @client.operations
      end

      def get_client_report(from, to = Time.now)
        result(@client.call(:get_client_report, message: {
                       ClientKey: SiteImpact.reports_api_key,
                       Start: from.iso8601,
                       EndDate: to.iso8601
                     }))
      end

      def get_link_report(campaign_id)
        result(@client.call(:get_link_report, message: {
                       ClientKey: SiteImpact.reports_api_key,
                       Campaignid: campaign_id
                     }))
      end

      def get_link_report_summary(campaign_id)
        result(@client.call(:get_link_report_summary, message: {
                       ClientKey: SiteImpact.reports_api_key,
                       Campaignid: campaign_id
                     }))
      end

      private

      def result(response)
        puts "SiteImpact -- Response: #{response.inspect}" if SiteImpact.config.debug
        if response.body.empty?
          raise SiteImpact::Error, 'No reporting results returned'
        end
        if (error = response.body[:error_response])
          raise SiteImpact::Error, error[:error_response_result][:message]
        end

        response.body
      end

    end
  end
end
