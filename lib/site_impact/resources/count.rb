# frozen_string_literal: true

module SiteImpact
  class Count
    class << self

      def categories
        client.get('api/categories')
      end

      def interests
        client.get('/api/categories/options', category: 'interests')
      end

      def options(category_name)
        client.get('/api/categories/options', category: category_name)
      end

      def counts
        client.get('/api/counts')
      end

      def create_count(zip_code, radius, categories_collection)
        client.post('/api/counts',
                    type: 'consumer',
                    groups: {
                      "1": {
                        geographies: geography(radius, zip_code),
                        selections: categories_collection.to_selections
                      }
                    },
                    settings: {
                      name: 'api1'
                    }
        )
      end

      def get(count_id, version_id)
        client.get("/api/counts/#{count_id}/check", version_id: version_id)
      end

      def preview(version_id)
        client.get("/api/counts/#{version_id}/preview/", version_id: version_id)
      end

      private

      def client
        SiteImpact::Client::Counts.new
      end

      def geography(radius, zip_code)
        if radius > SiteImpact.config.counts_max_radius
          return {
            nationwide: { include: ['Nationwide'] }
          }
        end

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
