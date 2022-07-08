# frozen_string_literal: true

module SiteImpact
  module Client
    class Reports < Base

      def initialize(**params)
        super(base_url: SiteImpact.reports_base_url)
      end

      private

      def headers
        {}
      end

    end
  end
end
