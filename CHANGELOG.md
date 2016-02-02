### Bug fixes

* [#157](https://github.com/withassociates/slices/pull/157): Fix issue where
sitemap wasn't showing correct icons for page types and wasn't showing child
pages in correct order (fixed in [#152](https://github.com/withassociates/slices/pull/152)
on master)

# 2.0.1 / 2016-02-02

### Bug fixes

* [#154](https://github.com/withassociates/slices/pull/154): Fix issue where
sitemap wasn't showing correct icons for page types and wasn't showing child
pages in correct order (fixed in [#152](https://github.com/withassociates/slices/pull/152)
on master)

# 2.0.0 / 2016-01-15

* Rails I18n support
* Refactor snippets to not piggy back on I18n
* Upgrade to mongoid v3.1
* Ensure (soft-)destroying an asset removes it from all pages/slices [#39](https://github.com/withassociates/slices/pull/39)
* Drop support for ruby 1.9

# 1.0.5 / 2014-08-21

* Add confirmation when deleting set entries
* Fix admin last-login date
* Fix token field in page meta

# 1.0.4 / 2014-06-06

* Remove omniauth

# 1.0.3 / 2014-03-12

* Put Page#as_json into its own module so it can be overridden in other modules
* Add rails generate slices:install command
* Upgrade Devise to 2.2.8

# 1.0.2 / 2014-01-13

* Fix (more) gem package issue

# 1.0.1 / 2014-01-13

* Fix gem package issue

# 1.0.0 / 2014-01-10

* Public release

