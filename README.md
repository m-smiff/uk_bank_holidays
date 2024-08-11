# UKBankHolidays

Welcome to the source code for the `UKBankHolidays` Ruby gem.

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add uk_bank_holidays

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install uk_bank_holidays

## Usage

### Default Data Source

This Gem is (by default) dependent on bank holiday data as published by the UK Government via [this](https://www.api.gov.uk/gds/bank-holidays/#bank-holidays) public API.

Without explicitly overriding, use of this gem is designed to be totally “offline”, i.e, the repository of dates/data referenced by the gem was copied and stored (exactly as published by the government) in a data structure within the code, and will have been “up to date” at the point of the version’s release.

Changes to the government data will cause a minor version bump.

It’s worth noting that this government data only seems to span a handful of years, e.g, at time or writing this (2024) it went back to 2018, and forward to 2026.

### Custom Data Source

#### `data_source`

If using the default data source doesn’t cut the mustard, you are free to define your own (as a `call`able object), bearing in mind the output of which must either be a `Hash`, or JSON string, and conform to the structure as utilised/designed by the UK Government...

```JSON
// UKBankHolidays.data_source = -> { JSON.parse(...
{
    // Top level keys MUST adhere to those used by GOV at time of release.
    // Currently "england-and-wales", "scotland", "northern-ireland".
    "england-and-wales": {
        "division": "england-and-wales",
        "events": [
            {
                "date": "2024-01-01",
                "title": "New Years Day",
                "notes": "", // Optional
                "bunting": false // Optional
            }
            // ... more events
        ]
    },
    "scotland": {
        // as above
    },
    "northern-ireland": {
        // as above
    }
}
```

The deserialized data will be memoized, so I'm afraid there's no option to have the data dynamically fetched (e.g., via HTTP requests).

### Divisions

For the purposes of the governance of Bank Holidays in the UK, the government splits the state in to 3 "divisions"; England and Wales (`"england-and-wales"`), Scotland ("`scotland`") and Northern Ireland (`"northern-ireland"`).

#### `default_division_context`

default: `england-and-wales` (`UKBankHolidays::Division`)

This defines within which context regarding of Bank Holidays is to be made, unless overriden as described herein.

```Ruby
UKBankHolidays.default_division_context = 'scotland'
```

#### `::with_division_context(division, &block)`

To allow for querying/referencing Bank Holiday dates for divisions other than the one defined as the "default", the stated method exists to override the default, yielding to allow for Bank Holiday related operations within the specified context, whilst knowing the default will remain unchanged.

```Ruby
Date.today # => 2025-01-01 (Bank Holiday in both England and Scotland)
UKBankHolidays.default_division_context # => england-and-wales

Date.today.bank_holiday? # => true
Date.today.to_bank_holiday.title # => "New Year's Day"
Date.today.next_bank_holiday # => 2025-04-18: Good Friday

UKBankHolidays.with_division_context('scotland') do
    Date.today.next_bank_holiday
end # => 2025-01-02: 2nd January

```

#### Acceptable Division Values

To provide some flexibility and save from potential wrangling around, when specifying a division for any of the relevant methods/contexts you can do so with one of a number of "acceptable" values, as thus:

`'england-and-wales' => %w[england wales eng wal england_and_wales england_wales england-wales]`<br/>
`'scotland' => %w[scot]`<br/>
`'northen-ireland' => %w[ni northern_ireland]`

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/uk_bank_holidays. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/uk_bank_holidays/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the UKBankHolidays project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/uk_bank_holidays/blob/main/CODE_OF_CONDUCT.md).
