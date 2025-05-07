require "spec_helper"

RSpec.describe SiteImpact::Report do
  let(:report_endpoint) {
    "https://ecampaignstats.com/cp/index.php/report_api/"
  }
  let(:get_client_report_response) do
    <<~XML
      <soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
        <soap:Body>
          <get_client_report_response xmlns="https://ecampaignstats.com/cp/index.php/report_api/">
            <get_client_report_result>
              <ds>
                <diffgram>
                  <new_data_set>
                    <table>
                      <campaign_x0020_id>12345</campaign_x0020_id>
                      <opens>100</opens>
                      <clicks>50</clicks>
                      <broadcast_x0020_date>2023-01-01T00:00:00Z</broadcast_x0020_date>
                    </table>
                  </new_data_set>
                </diffgram>
              </ds>
            </get_client_report_result>
          </get_client_report_response>
        </soap:Body>
      </soap:Envelope>
    XML
  end

  let(:client) { described_class }
  let(:from) { Time.parse("2023-01-01") }

  before do
    stub_request(:get, SiteImpact.reports_base_url)
      .to_return(
        status: 200,
        headers: { 'Content-Type' => 'text/xml' },
        body: File.read("spec/fixtures/service.wsdl")
      )

    stub_request(:post, report_endpoint).
      with(
        headers: {
          'Soapaction'=>'"https://ecampaignstats.com/cp/index.php/report_api/GetClientReport"',
        }).
      to_return(status: 200, body: get_client_report_response, headers: {})
  end

  describe "#get_client_report" do
    context "when a valid response is returned" do
      it "returns the response body" do
        result = client.get_client_report(from)
        expect(result).to_not be_nil
      end
    end

    context "when the response is empty" do
      before do
        stub_request(:post, report_endpoint).
          with(
            headers: {
              'Soapaction'=>'"https://ecampaignstats.com/cp/index.php/report_api/GetClientReport"',
            }).
          to_return(status: 200, body: nil, headers: {})
      end

      it "raises an error" do
        expect { client.get_client_report(from) }.to raise_error(Savon::InvalidResponseError)
      end
    end
  end
end
