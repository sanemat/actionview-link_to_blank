# ActionView::LinkToBlank

[![Gem Version](https://badge.fury.io/rb/actionview-link_to_blank.png)](http://badge.fury.io/rb/actionview-link_to_blank)
[![Build Status](https://api.travis-ci.org/sanemat/actionview-link_to_blank.png?branch=master)](https://travis-ci.org/sanemat/actionview-link_to_blank)
[![Code Climate](https://codeclimate.com/github/sanemat/actionview-link_to_blank.png)](https://codeclimate.com/github/sanemat/actionview-link_to_blank)
[![Coverage Status](https://coveralls.io/repos/sanemat/actionview-link_to_blank/badge.png?branch=master)](https://coveralls.io/r/sanemat/actionview-link_to_blank)
[![Dependency Status](https://gemnasium.com/sanemat/actionview-link_to_blank.png)](https://gemnasium.com/sanemat/actionview-link_to_blank)

Add helper method, link_to_blank, equal to link_to with target _blank
Add helper method, link_to_blank_if, link_to_blank_unless, link_to_blank_unless_current.
This is symmetrical to link_to_if, link_to_unless, link_to_unless_current.

## Installation

Add this line to your application's Gemfile:

    gem 'actionview-link_to_blank'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install actionview-link_to_blank

## Usage

Use the `link_to_blank` helper method, equal `link_to('foo', target: '_blank')`

### Signatures

    link_to_blank(body, url, html_options = {})
      # url is a String; you can use URL helpers like
      # posts_path

    link_to_blank(body, url_options = {}, html_options = {})
      # url_options, except :confirm or :method,
      # is passed to url_for

    link_to_blank(options = {}, html_options = {}) do
      # name
    end

    link_to_blank(url, html_options = {}) do
      # name
    end

    link_to_blank_if(condition, name, options = {}, html_options = {})
      # if condition is true, create a link tag
      # otherwise only name

    link_to_blank_unless(condition, name, options = {}, html_options = {})
      # if condition is true, only name
      # otherwise create a link tag

    link_to_blank_unless_current(name, options = {}, html_options = {})
      # create a link tag of the given name unless current page is the same

### Examples

    link_to_blank "Profile", profile_path(@profile)
    # => <a href="/profiles/1" target="_blank">Profile</a>

    <%= link_to_blank(@profile) do %>
      <strong><%= @profile.name %></strong> -- <span>Check it out!</span>
    <% end %>
    # => <a href="/profiles/1" target="_blank">
           <strong>David</strong> -- <span>Check it out!</span>
         </a>

## Testing

    $ bundle exec rake

If you want to run against actionpack v3.2, v4.0, v4.1, v4.2, v5.0 and master run below:

    $ bundle exec appraisal install
    $ bundle exec appraisal rake

Test for specific version:

    $ bundle exec appraisal install
    $ bundle exec appraisal rails_4_0 rake

Prepare rails_3_2(gem), rails_4_0(gem), rails_4_1(gem),
rails_4_2(gem), rails_5_0(gem), rails_master(github)

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
