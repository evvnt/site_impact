# frozen_string_literal: true

module SiteImpact
  class Count
    class << self

      def categories
        klass.categories
      end

      def interests
        klass.interests
      end

      def options(category_name)
        klass.options(category_name)
      end

      def counts
        klass.counts
      end

      def create_count(zip_code, radius, categories_collection)
        klass.create_count(zip_code, radius, categories_collection)
      end

      def get(count_id, version_id)
        klass.get(count_id, version_id)
      end

      def preview(version_id)
        klass.preview(version_id)
      end

      private

      def klass
        self.new
      end

    end

    attr_reader :client

    # Provide a instance version of this so repeated calls can be made without re-running `authenticate` on the client
    def initialize
      @client = SiteImpact::Client::Counts.new
    end

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
                  {
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
