Voxer::Chef::Formatter
======================

Voxer's Chef Formatter improves the output of a chef-client or chef-solo run to be useful.

Features
--------

Based on the chef [minimal formatter](https://github.com/opscode/chef/blob/master/lib/chef/formatters/minimal.rb)

updates include

- live updates as resources are updated (output isn't queued until the end of the run)
- colorized diffs
- file written to at the end with status information if `ENV['VOXER_FORMATTER_FILE']` is set
- more verbose error messages

Note: this formatter is best used with log_level :warn

Installation
------------

Add this line to your application's Gemfile:

```ruby
gem 'voxer-chef-formatter'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install voxer-chef-formatter

Contributing
------------

1. Fork it ( https://github.com/[my-github-username]/voxer-chef-formatter/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
