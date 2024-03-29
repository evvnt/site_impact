# SiteImpact

A gem with Ruby bindings for the Site Impact Orders, Counts and Reporting APIs.

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add site_impact

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install site_impact

## Usage

### Orders
```ruby
require 'site_impact'

SiteImpact.orders_base_url = 'https://sandbox.oms.siteimpact.com/api/v2/'
SiteImpact.orders_api_key = 'YOUR KEY HERE'
# Add other config variables...

order = SiteImpact::Order.create(params)
SiteImpact::Order.approve(order.id)
SiteImpact::Order.read(order.id)
```

### Counts
```ruby
require 'site_impact'
# Categories and interests
categories = SiteImpact::Count.categories
options = SiteImpact::Count.options(categories.first)
# Created and get counts
response = SiteImpact::Count.create_count(zip_code, radius, categories_collection)
count = SiteImpact::Count.get(response['data']['id'], response['data']['version_id'])
```
The Counts API requires a temporary auth token on each request. When making repeated requests with `SiteImapct::Count` it is more efficient to use an instance. The authentication request will only be run once:
```ruby
client = SiteImpact::Count.new
radii = [10, 20, 30, 50, 80]

radii.each do |radius|
  client.create_count(zip_code, radius, categories_collection)
end
```


### Reports
```ruby
require 'site_impact'
SiteImpact.reports_base_url = 'http://sandbox.ecampaignstats.com/cp/index.php/report_api/?WSDL'
SiteImpact.reports_api_key = '[Your Reports Key]'

start_time = 90.days.ago
report = ::SiteImpact::Report.get_client_report(start_time)
puts "Your campaign has #{report.opens} opens, #{report.clicks} unique clicks and a broadcast date of #{report.broadcast_time}"
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/evvnt/site_impact. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/site_impact/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the SiteImpact project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/evvnt/site_impact/blob/master/CODE_OF_CONDUCT.md).
