# ActionView::LinkToBlank

[![Build Status](https://api.travis-ci.org/sanemat/actionview-link_to_blank.png?branch=master)](https://travis-ci.org/sanemat/actionview-link_to_blank)

Add helper method, link_to_blank, equal to link_to with target _blank

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

If you want to run against actionpack v3 and v4, run below:

    $ bundle --gemfile=gemfiles/rails3.2/Gemfile --path=.bundle
    # this install gems to gemfiles/rails3.2/.bundle/xxx
    $ bundle exec rake BUNDLE_GEMFILE=gemfiles/rails3.2/Gemfile

    $ bundle --gemfile=gemfiles/rails4.0/Gemfile --path=.bundle
    # this install gems to gemfiles/rails4.0/.bundle/xxx
    $ bundle exec rake BUNDLE_GEMFILE=gemfiles/rails4.0/Gemfile

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
