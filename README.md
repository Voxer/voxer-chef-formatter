Voxer Chef Formatter
====================

Voxer's chef formatter

Features
--------

Based on the chef [minimal formatter](https://github.com/opscode/chef/blob/master/lib/chef/formatters/minimal.rb)

updates include

- live updates as resources are updated (output isn't queued until the end of the run)
- colorized diffs
- more verbose error messages
- indentation to match depth of LWRP's (`use_inline_resources`)
- file written to at the end with status information if `ENV['VOXER_FORMATTER_FILE']` is set
- syslog line generated when chef runs successfully if `ENV['VOXER_FORMATTER_SYSLOG']` is set

Note: this formatter is best used with `log_level` :warn

Example
-------

```
* reload[ssh]
     - reload service service[ssh]

* service[rsyslog]
     - restart service service[rsyslog]

* stud[example-stud-process]
   * voxer_service[example-stud-process]
      * smf_service[example-stud-process]
         * file[/opt/local/share/smf/manifest/chef/application/network/example-stud-process.xml]
              - update content in file /opt/local/share/smf/manifest/chef/application/network/example-stud-process.xml from a3ef5a to 498e4d

                    --- /opt/local/share/smf/manifest/chef/application/network/example-stud-process.xml      2015-02-17 18:21:57.082839531 -0500
                    +++ /opt/local/share/smf/manifest/chef/application/network/.example-stud-process.xml20150316-2553-q17bu2 2015-03-16 21:16:55.223940196 -0400
                    @@ -25,7 +22,7 @@
                             <exec_method type="method" name="stop" exec=":kill" timeout_seconds="30" />
                             <template >
                                 <common_name >
                    -                <loctext xml:lang="C" >Lame Stud Process</loctext>
                    +                <loctext xml:lang="C" >Cool Stud Process</loctext>
                                 </common_name>
                             </template>
                         </service>

         * execute[Import SMF Manifest for application/network/example-stud-process]
              - execute ["svccfg", "import", "/opt/local/share/smf/manifest/chef/application/network/example-stud-process.xml"]
```

From the above example you can see that at Voxer we have a couple LWRP's that call other LWRP's.
In this example `stud` calls `voxer_service` calls `smf_service` calls `file`.  Instead of showing
all of these on the same level, this formatter indents them to show the hierarchy.

Installation
------------

Pull the formatter into your chef repository

    mkdir -p formatters
    curl https://raw.githubusercontent.com/Voxer/voxer-chef-formatter/master/voxer.rb > formatters/voxer.rb

Now, configure it by adding some of these lines to your config.  At Voxer, we have this in
`solo.rb`.

``` ruby
ENV['VOXER_FORMATTER_FILE']   ||= '/etc/chef/LAST-RUN'
ENV['VOXER_FORMATTER_SYSLOG'] ||= '1'

root_path     File.dirname(File.realpath(File.absolute_path(__FILE__)))
add_formatter :voxer
require       File.join(root_path, 'formatters/voxer')
```

Note that this formatter assumes `root_path` is set in the chef config
to the path of the chef directory

License
-------

```
The MIT License

Copyright 2007-2015, Voxer, Inc

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
