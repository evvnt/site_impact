# frozen_string_literal: true

module SiteImpact
  module Client
    class Counts < Base

      def initialize(**params)
        super(base_url: SiteImpact.counts_base_url)
      end

      private

      def headers
        {}
      end

    end
  end
end
