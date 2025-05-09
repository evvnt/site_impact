# frozen_string_literal: true

module SiteImpact
  class Order
    class << self
      def create(opts = {})
        client.post("orders", create_order_body(opts))
      end

      def update(order_id, opts = {})
        client.patch("orders/#{order_id}", update_order_body(opts))
      end

      def read(order_id)
        client.get("orders/#{order_id}")
      end

      def approve(order_id, opts)
        client.post("orders/#{order_id}/approvals",
                    {
                      data: {
                        broadcast_date: opts[:broadcast_date],
                        broadcast_time: opts[:broadcast_time],
                        broadcast_timezone: 1,
                      }
                    }
        )
      end

      def unapprove_order(order_id)
        client.delete("orders/#{order_id}/approvals")
      end

      def search(params = {})
        params.slice!(:order_name, :po_number, :broadcast_date, :order_status_id, :order_type_id).compact
        client.get("orders", params)
      end

      def test_connection
        client.get("test")
      end

      private

      def client
        SiteImpact::Client::Orders.new()
      end

      def create_order_body(opts)
        {
          data: {
            orders: [
              {
                order_type_id: 1,
                order_name: opts[:order_name],
                pricing: 0,
                broadcast_date: opts[:broadcast_date],
                broadcast_time: opts[:broadcast_time],
                broadcast_timezone: 1,
                quantity: opts[:quantity],
                has_suppression: 0,
                has_personalization: 0,
                has_tracking_pixel: 0,
                subject_line: opts[:subject_line],
                test_seeds: SiteImpact.orders_test_seeds,
                live_seeds: SiteImpact.orders_live_seeds,
                tracking_login_id: SiteImpact.orders_tracking_login_id,
                from_address_id: SiteImpact.orders_from_address_id,
                image_host_id: SiteImpact.orders_image_host_id,
                test_tracking_link_id: SiteImpact.orders_test_tracking_link_id,
                files: [
                  {
                    order_file_type_id: 2,
                    base64: opts[:email_content],
                    file_name: "creative.zip"
                  }
                ],
                from_line: opts[:from_name],
                opt_out_id: SiteImpact.orders_opt_out_id,
                count_version_id: opts[:count_version_id],
                use_auto_testing: true
              }
            ]
          }
        }
      end

      def update_order_body(opts)
        changes = {
          order_name: opts[:order_name],
          broadcast_date: opts[:broadcast_date],
          broadcast_time: opts[:broadcast_time],
          quantity: opts[:quantity],
          subject_line: opts[:subject_line],
          po_number: opts[:po_number],
          from_line: opts[:from_name],
          count_version_id: opts[:count_version_id],
        }.compact
        if opts[:email_content]
          changes[:files] = [
            {
              order_file_type_id: 2,
              base64: opts[:email_content],
              file_name: "creative.zip"
            }
          ]
        end
        {
          data: {
            changes: changes,
            retest: opts.fetch(:retest){ false },
            comments: ""
          }
        }
      end

    end
  end
end
