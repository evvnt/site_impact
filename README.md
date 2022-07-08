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
# TODO
```

### Reports
```ruby
# TODO
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
