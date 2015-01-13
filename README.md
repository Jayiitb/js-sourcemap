# JsSourcemap

This helps in generating js-sourcemap for js files.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'js-sourcemap', "0.0.4"
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install js-sourcemap

## Usage

Copy and paste the sourcemap.yml.sample file as sourcemap.yml in the project, sourcemap is to be integrated.
Sourcemap.yml file contains all the config that needs to be done for sourcemapping.

For generating sourcemap, run task:

	bundle exec rake smap:generate_mapping


For cleaning of unused files, run:

	bundle exec rake smap:clean


For syncing the generated map and original files to s3, run:

	bundle exec rake smap:sync_to_s3

Or else do all at once (map generation,cleanup & syncing), with:

	bundle exec rake smap:complete_build

Done!

## Contributing

1. Fork it ( https://github.com/[my-github-username]/js-sourcemap/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
