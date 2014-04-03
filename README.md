# fixme

FIXME comments that raise after a certain point in time:

```
FIXME "2014-07-31: Stop hard-coding currency."
currency = "USD"
```

This library makes a `FIXME()` method available everywhere.

Starting July 31st 2014, the "FIXME" line in the example above would raise `Fixme::UnfixedError` with the message `"Fix by 2014-07-31: Stop hard-coding currency."`

You may want to use these bad boys next to:

  * Temporary quick fixes, to ensure they really *are* temporary.
  * Code that supports legacy workflows during a transitional period.
  * Experiments, to remember to evaluate them and make a decision.
  * Anything else you can't do now but should fix later.

If `Rails.environment` (Ruby on Rails) or `ENV["RACK_ENV"]` (e.g. Sinatra) is present, it will only ever raise in the `"test"` and `"development"` environments. That is, the production app will never raise these exceptions.

If you don't want your CI server to raise, make it set the environment variable `DO_NOT_RAISE_FIXMES`. I like having CI raise them, though.

Protip: make sure it's clear from the exception or from a separate comment just what should be done – sometimes not even the person who wrote the quickfix will remember what you're meant to change.

This library is an extraction of a helper (originally called `wip_raise`) we tried and liked at [Barsoom](http://barsoom.se).


## Installation

Add this line to your application's Gemfile:

    gem 'fixme'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install fixme


## Develop

Clone the repo, then:

```
bundle  # Install gem dependencies.
rake    # Run tests.
```


## License

Copyright (c) 2014 Henrik Nyh

MIT License

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
