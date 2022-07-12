# frozen_string_literal: true

module SiteImpact
  class Count
    class << self

      def categories
        self.client.get("api/categories")
      end

      def interests
        self.client.get("/api/categories/options", { category: 'interests' })
      end

      def options(category_name)
        self.client.get("/api/categories/options", { category: category_name })
      end

      def counts
        self.client.get("/api/counts")
      end

      def create_count(zip_code, radius, categories_collection)
        self.client.post("/api/counts", {
          type: "consumer",
          groups: {
            "1": {
              geographies: self.geography(radius, zip_code),
              selections: categories_collection.to_selections
            }
          },
          settings: {
            name: "api1"
          }
        })
      end

      def get(count_id, version_id)
        self.client.get("/api/counts/#{count_id}/check", { version_id: version_id })
      end

      def preview(version_id)
        self.client.get("/api/counts/#{version_id}/preview/", { version_id: version_id })
      end

      private

      def client
        SiteImpact::Client::Counts.new()
      end

      def geography(radius, zip_code)
        return {
          nationwide: { include: ["Nationwide"] }
        } if radius > SiteImpact.config.counts_max_radius

        {
          zip_code: {
            include: [
              radius.to_i > 0 ? "#{zip_code}:#{radius}" : zip_code
            ]
          }
        }
      end
    end
  end
end
