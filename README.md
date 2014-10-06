Voxer Chef Formatter
====================

Voxer's chef formatter

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

Pull the formatter into your chef repository

    mkdir -p formatters
    curl https://raw.githubusercontent.com/Voxer/voxer-chef-formatter/master/voxer.rb > formatters/voxer.rb

Now, configure it by adding some of these lines to your config.  At Voxer, we have this in
`solo.rb`.


``` ruby
ENV['VOXER_FORMATTER_FILE'] ||= '/etc/chef/LAST-RUN'

root_path     File.dirname(File.realpath(File.absolute_path(__FILE__)))
add_formatter :voxer
require       File.join(root_path, 'formatters/voxer')
```

License
-------

```
The MIT License

Copyright 2007-2014, Voxer, Inc

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```
