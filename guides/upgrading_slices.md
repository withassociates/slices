# Upgrading Slices

## Upgrading from Slices 2.0 to Slices 3.0

The bulk of the work here is upgrading to Rails 4, so the the best place to
start is to follow the [Rails upgrading guide](http://edgeguides.rubyonrails.org/upgrading_ruby_on_rails.html).
We also upgrading the following gems:
  * Mongoid 4 (there no upgrade guide, but here's the [changelog](https://github.com/mongodb/mongoid/blob/v4.0.2/CHANGELOG.md))
  * Devise 3.2 ([guide](https://github.com/plataformatec/devise/wiki/How-To:-Upgrade-to-Devise-3.1))

Any use of `Page#text_search` needs to be updated to `Page#basic_text_search`
http://www.rubydoc.info/gems/mongoid/4.0.0/Mongoid%2FContextual%2FMongo%3Atext_search

`PagesHelper#google_analytics_tracking_code` has been removed, visit [google.com/analytics](http://www.google.com/analytics/)
and use the upto date tracking code.

