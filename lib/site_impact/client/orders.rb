# frozen_string_literal: true

module SiteImpact
  module Client
    class Orders < Base

      def initialize(**params)
        super(base_url: SiteImpact.orders_base_url)
      end

      private

      def headers
        {
          "api-key" => SiteImpact.orders_api_key,
          "Content-Type" => "application/json",
          "User-Agent" => "Ruby",
        }
      end

    end
  end
end
