# AktionCap

A metagem for use with capistrano. It includes capistrano with multistage extension, rvm integration and rake tasks to make capistrano management simpler.

## Installation

Add this line to your application's Gemfile:

    gem 'aktion_cap', '~> 0.1.0'

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install aktion_cap

## Usage

### capify

The `rake capify` command acts as a replacement for `capify`. When run it will prompt a series of questions about the deployment and output files
fully configured for deployment. The prompts will attempt to supply defaults based on the application.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
