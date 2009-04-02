= Pangea 0.1

* http://www.xen-fu.org/blog

== DESCRIPTION:

Xen-Api Ruby Implementation

== FEATURES/PROBLEMS:

* Read-only operations implemented ATM
* Needs documentation
* Add more examples
* API is subject to change till we reach 1.0

== SYNOPSIS:

  require 'rubygems'

  require 'pangea'

  host = Pangea::Host.connect('http://xen.example.net:9363', 'foo', 'bar')

  host.resident_vms.each do |vm|
    # do something with the Pangea::VM object
  end

  host.networks.each do |net|
    # do something with the Pangea::Network object
  end

== REQUIREMENTS:

* Ruby1.8.7 is required (XObject.ref_call doesn't work in ruby1.8.6

== INSTALL:

* gem source -a \http://gems.xen-fu.org
* gem install pangea

== LICENSE:

(The MIT License)

Copyright (c) 2008 FIX

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
