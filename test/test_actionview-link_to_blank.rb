# coding: utf-8
require 'coveralls'
Coveralls.wear!

require 'minitest/autorun'
require 'active_support'
require 'active_support/concern'
require 'active_support/deprecation'
require 'active_support/core_ext'
require 'active_support/testing/deprecation'
require 'action_controller'
require 'action_view'
require 'action_view/link_to_blank/link_to_blank'
require 'action_dispatch'
require 'rails-dom-testing' if Gem::Version.new(ActionPack::VERSION::STRING) >= Gem::Version.new("4.2")

# Copy from actionpack/test/abstract_unit.rb
module RenderERBUtils
  def render_erb(string)
    @virtual_path = nil

    template = ActionView::Template.new(
      string.strip,
      "test template",
      ActionView::Template::Handlers::ERB,
      {})

    template.render(self, {}).strip
  end
end

# Rails4.1, this code is here:
# actionview/test/template/url_helper_test.rb
# and base class is ActiveSupport::TestCase

# Ensure backward compatibility with Minitest 4
Minitest::Test = MiniTest::Unit::TestCase unless defined?(Minitest::Test)

class TestActionViewLinkToBlank < MiniTest::Test
  # In a few cases, the helper proxies to 'controller'
  # or request.
  #
  # In those cases, we'll set up a simple mock
  attr_accessor :controller, :request

  cattr_accessor :request_forgery
  self.request_forgery = false

  routes = ActionDispatch::Routing::RouteSet.new
  routes.draw do
    get "/" => "foo#bar"
    get "/other" => "foo#other"
    get "/article/:id" => "foo#article", :as => :article
  end

  include ActionView::Helpers::UrlHelper
  include routes.url_helpers

  dom_assertion = Gem::Version.new(ActionPack::VERSION::STRING) < Gem::Version.new("4.2")\
  ? ActionDispatch::Assertions::DomAssertions
  : Rails::Dom::Testing::Assertions::DomAssertions

  include dom_assertion
  include ActiveSupport::Testing::Deprecation
  include ActionView::Context
  include RenderERBUtils

  def hash_for(options = {})
    { controller: "foo", action: "bar" }.merge!(options)
  end
  alias url_hash hash_for

  def test_initialization
    [:link_to_blank].each do |method|
      assert_includes ActionView::Helpers::UrlHelper.instance_methods, method
    end
  end

  def test_link_tag_with_straight_url
    assert_dom_equal %{<a href="http://www.example.com" target="_blank">Hello</a>}, link_to_blank("Hello", "http://www.example.com")
  end

  def test_link_tag_without_host_option
    assert_dom_equal(%{<a href="/" target="_blank">Test Link</a>}, link_to_blank('Test Link', url_hash))
  end

  def test_link_tag_with_host_option
    hash = hash_for(host: "www.example.com")
    expected = %{<a href="http://www.example.com/" target="_blank">Test Link</a>}
    assert_dom_equal(expected, link_to_blank('Test Link', hash))
  end

  def test_link_tag_with_query
    expected = %{<a href="http://www.example.com?q1=v1&amp;q2=v2" target="_blank">Hello</a>}
    assert_dom_equal expected, link_to_blank("Hello", "http://www.example.com?q1=v1&q2=v2")
  end

  def test_link_tag_with_query_and_no_name
    expected = %{<a href="http://www.example.com?q1=v1&amp;q2=v2" target="_blank">http://www.example.com?q1=v1&amp;q2=v2</a>}
    assert_dom_equal expected, link_to_blank(nil, "http://www.example.com?q1=v1&q2=v2")
  end

  def test_link_tag_with_back
    env = {"HTTP_REFERER" => "http://www.example.com/referer"}
    @controller = Struct.new(:request).new(Struct.new(:env).new(env))
    expected = %{<a href="#{env["HTTP_REFERER"]}" target="_blank">go back</a>}
    assert_dom_equal expected, link_to_blank('go back', :back)
  end

  def test_link_tag_with_back_and_no_referer
    @controller = Struct.new(:request).new(Struct.new(:env).new({}))
    link = link_to_blank('go back', :back)
    assert_dom_equal %{<a href="javascript:history.back()" target="_blank">go back</a>}, link
  end

  def test_link_tag_with_img
    link = link_to_blank("<img src='/favicon.jpg' />".html_safe, "/")
    expected = %{<a href="/" target="_blank"><img src='/favicon.jpg' /></a>}
    assert_dom_equal expected, link
  end

  def test_link_with_nil_html_options
    link = link_to_blank("Hello", url_hash, nil)
    assert_dom_equal %{<a href="/" target="_blank">Hello</a>}, link
  end

  def test_link_tag_with_custom_onclick
    link = link_to_blank("Hello", "http://www.example.com", onclick: "alert('yay!')")
    # NOTE: differences between AP v3 and v4
    escaped_onclick = ActionPack::VERSION::MAJOR == 3 ? %{alert(&#x27;yay!&#x27;)} : %{alert(&#39;yay!&#39;)}
    expected = %{<a href="http://www.example.com" onclick="#{escaped_onclick}" target="_blank">Hello</a>}
    assert_dom_equal expected, link
  end

  def test_link_tag_with_javascript_confirm
    assert_dom_equal(
      %{<a href="http://www.example.com" data-confirm="Are you sure?" target="_blank">Hello</a>},
      link_to_blank("Hello", "http://www.example.com", data: { confirm: "Are you sure?" })
    )
    assert_dom_equal(
      %{<a href="http://www.example.com" data-confirm="You cant possibly be sure, can you?" target="_blank">Hello</a>},
      link_to_blank("Hello", "http://www.example.com", data: { confirm: "You cant possibly be sure, can you?" })
    )
    assert_dom_equal(
      %{<a href="http://www.example.com" data-confirm="You cant possibly be sure,\n can you?" target="_blank">Hello</a>},
      link_to_blank("Hello", "http://www.example.com", data: { confirm: "You cant possibly be sure,\n can you?" })
    )
  end

  def test_link_tag_with_deprecated_confirm
    skip('Not deprecate in Rails3.2') if Gem::Version.new(ActionPack::VERSION::STRING) < Gem::Version.new('4')
    skip('Remove in Rails4.1') if Gem::Version.new(ActionPack::VERSION::STRING) >= Gem::Version.new('4.1')
    assert_deprecated ":confirm option is deprecated and will be removed from Rails 4.1. Use 'data: { confirm: \'Text\' }' instead" do
      assert_dom_equal(
        %{<a href="http://www.example.com" data-confirm="Are you sure?" target="_blank">Hello</a>},
        link_to_blank("Hello", "http://www.example.com", confirm: "Are you sure?")
      )
    end
    assert_deprecated ":confirm option is deprecated and will be removed from Rails 4.1. Use 'data: { confirm: \'Text\' }' instead" do
      assert_dom_equal(
        %{<a href="http://www.example.com" data-confirm="You cant possibly be sure, can you?" target="_blank">Hello</a>},
        link_to_blank("Hello", "http://www.example.com", confirm: "You cant possibly be sure, can you?")
      )
    end
    assert_deprecated ":confirm option is deprecated and will be removed from Rails 4.1. Use 'data: { confirm: \'Text\' }' instead" do
      assert_dom_equal(
        %{<a href="http://www.example.com" data-confirm="You cant possibly be sure,\n can you?" target="_blank">Hello</a>},
        link_to_blank("Hello", "http://www.example.com", confirm: "You cant possibly be sure,\n can you?")
      )
    end
  end

  def test_link_to_with_remote
    assert_dom_equal(
      %{<a href="http://www.example.com" data-remote="true" target="_blank">Hello</a>},
      link_to_blank("Hello", "http://www.example.com", remote: true)
    )
  end

  def test_link_to_with_remote_false
    assert_dom_equal(
      %{<a href="http://www.example.com" target="_blank">Hello</a>},
      link_to_blank("Hello", "http://www.example.com", remote: false)
    )
  end

  def test_link_to_with_symbolic_remote_in_non_html_options
    assert_dom_equal(
      %{<a href="/" data-remote="true" target="_blank">Hello</a>},
      link_to_blank("Hello", hash_for(remote: true), {})
    )
  end

  def test_link_to_with_string_remote_in_non_html_options
    assert_dom_equal(
      %{<a href="/" data-remote="true" target="_blank">Hello</a>},
      link_to_blank("Hello", hash_for('remote' => true), {})
    )
  end

  def test_link_tag_using_post_javascript
    assert_dom_equal(
      %{<a href="http://www.example.com" data-method="post" rel="nofollow" target="_blank">Hello</a>},
      link_to_blank("Hello", "http://www.example.com", method: :post)
    )
  end

  def test_link_tag_using_delete_javascript
    assert_dom_equal(
      %{<a href="http://www.example.com" rel="nofollow" data-method="delete" target="_blank">Destroy</a>},
      link_to_blank("Destroy", "http://www.example.com", method: :delete)
    )
  end

  def test_link_tag_using_delete_javascript_and_href
    assert_dom_equal(
      %{<a href="\#" rel="nofollow" data-method="delete" target="_blank">Destroy</a>},
      link_to_blank("Destroy", "http://www.example.com", method: :delete, href: '#')
    )
  end

  def test_link_tag_using_post_javascript_and_rel
    assert_dom_equal(
      %{<a href="http://www.example.com" data-method="post" rel="example nofollow" target="_blank">Hello</a>},
      link_to_blank("Hello", "http://www.example.com", method: :post, rel: 'example')
    )
  end

  def test_link_tag_using_post_javascript_and_confirm
    assert_dom_equal(
      %{<a href="http://www.example.com" data-method="post" rel="nofollow" data-confirm="Are you serious?" target="_blank">Hello</a>},
      link_to_blank("Hello", "http://www.example.com", method: :post, data: { confirm: "Are you serious?" })
    )
  end

  def test_link_tag_using_post_javascript_and_with_deprecated_confirm
    skip('Not deprecate in Rails3.2') if Gem::Version.new(ActionPack::VERSION::STRING) < Gem::Version.new('4')
    skip('Remove in Rails4.1') if Gem::Version.new(ActionPack::VERSION::STRING) >= Gem::Version.new('4.1')
    assert_deprecated ":confirm option is deprecated and will be removed from Rails 4.1. Use 'data: { confirm: \'Text\' }' instead" do
      assert_dom_equal(
        %{<a href="http://www.example.com" data-method="post" rel="nofollow" data-confirm="Are you serious?" target="_blank">Hello</a>},
        link_to_blank("Hello", "http://www.example.com", method: :post, confirm: "Are you serious?")
      )
    end
  end

  def test_link_tag_using_delete_javascript_and_href_and_confirm
    assert_dom_equal(
      %{<a href="\#" rel="nofollow" data-confirm="Are you serious?" data-method="delete" target="_blank">Destroy</a>},
      link_to_blank("Destroy", "http://www.example.com", method: :delete, href: '#', data: { confirm: "Are you serious?" })
    )
  end

  def test_link_tag_using_delete_javascript_and_href_and_with_deprecated_confirm
    skip('Not deprecate in Rails3.2') if Gem::Version.new(ActionPack::VERSION::STRING) < Gem::Version.new('4')
    skip('Remove in Rails4.1') if Gem::Version.new(ActionPack::VERSION::STRING) >= Gem::Version.new('4.1')
    assert_deprecated ":confirm option is deprecated and will be removed from Rails 4.1. Use 'data: { confirm: \'Text\' }' instead" do
      assert_dom_equal(
        %{<a href="\#" rel="nofollow" data-confirm="Are you serious?" data-method="delete" target="_blank">Destroy</a>},
        link_to_blank("Destroy", "http://www.example.com", method: :delete, href: '#', confirm: "Are you serious?")
      )
    end
  end

  def test_link_tag_with_block
    assert_dom_equal %{<a href="/" target="_blank"><span>Example site</span></a>},
      link_to_blank('/') { content_tag(:span, 'Example site') }
  end

  def test_link_tag_with_block_and_html_options
    assert_dom_equal %{<a class="special" href="/" target="_blank"><span>Example site</span></a>},
      link_to_blank('/', class: "special") { content_tag(:span, 'Example site') }
  end

  def test_link_tag_using_block_and_hash
    assert_dom_equal(
      %{<a href="/" target="_blank"><span>Example site</span></a>},
      link_to_blank(url_hash) { content_tag(:span, 'Example site') }
    )
  end

  def test_link_tag_using_block_in_erb
    out = render_erb %{<%= link_to_blank('/') do %>Example site<% end %>}
    assert_dom_equal '<a href="/" target="_blank">Example site</a>', out
  end

  def test_link_tag_with_html_safe_string
    assert_dom_equal(
      %{<a href="/article/Gerd_M%C3%BCller" target="_blank">Gerd Müller</a>},
      link_to_blank("Gerd Müller", article_path("Gerd_Müller".html_safe))
    )
  end

  def test_link_tag_escapes_content
    assert_dom_equal %{<a href="/" target="_blank">Malicious &lt;script&gt;content&lt;/script&gt;</a>},
      link_to_blank("Malicious <script>content</script>", "/")
  end

  def test_link_tag_does_not_escape_html_safe_content
    assert_dom_equal %{<a href="/" target="_blank">Malicious <script>content</script></a>},
      link_to_blank("Malicious <script>content</script>".html_safe, "/")
  end

  def test_link_tag_override_specific
    assert_dom_equal %{<a href="http://www.example.com" target="override">Hello</a>}, link_to_blank("Hello", "http://www.example.com", target: 'override')
  end

  def test_link_to_unless
    assert_equal "Showing", link_to_blank_unless(true, "Showing", url_hash)

    assert_dom_equal %{<a href="/" target="_blank">Listing</a>},
      link_to_blank_unless(false, "Listing", url_hash)

    assert_equal "Showing", link_to_blank_unless(true, "Showing", url_hash)

    assert_equal "<strong>Showing</strong>",
      link_to_blank_unless(true, "Showing", url_hash) { |name|
        "<strong>#{name}</strong>".html_safe
      }

    assert_equal "test",
      link_to_blank_unless(true, "Showing", url_hash) {
        "test"
      }

    # FIXME
    assert_equal %{&lt;b&gt;Showing&lt;/b&gt;}, link_to_blank_unless(true, "<b>Showing</b>", url_hash)
    assert_equal %{<a href="/">&lt;b&gt;Showing&lt;/b&gt;</a>}, link_to_unless(false, "<b>Showing</b>", url_hash)
    assert_equal %{<b>Showing</b>}, link_to_unless(true, "<b>Showing</b>".html_safe, url_hash)
    assert_equal %{<a href="/"><b>Showing</b></a>}, link_to_unless(false, "<b>Showing</b>".html_safe, url_hash)
  end

  def test_link_to_if
    assert_equal "Showing", link_to_blank_if(false, "Showing", url_hash)
    assert_dom_equal %{<a href="/" target="_blank">Listing</a>}, link_to_blank_if(true, "Listing", url_hash)
  end

  def request_for_url(url, opts = {})
    env = Rack::MockRequest.env_for("http://www.example.com#{url}", opts)
    ActionDispatch::Request.new(env)
  end

  def test_link_unless_current
    @request = request_for_url("/")

    assert_equal "Showing",
      link_to_blank_unless_current("Showing", url_hash)
    assert_equal "Showing",
      link_to_blank_unless_current("Showing", "http://www.example.com/")

    @request = request_for_url("/?order=desc")

    assert_equal "Showing",
      link_to_blank_unless_current("Showing", url_hash)
    assert_equal "Showing",
      link_to_blank_unless_current("Showing", "http://www.example.com/")

    @request = request_for_url("/?order=desc&page=1")

    assert_equal "Showing",
      link_to_blank_unless_current("Showing", hash_for(order: 'desc', page: '1'))
    assert_equal "Showing",
      link_to_blank_unless_current("Showing", "http://www.example.com/?order=desc&page=1")

    @request = request_for_url("/?order=desc")

    assert_dom_equal %{<a href="/?order=asc" target="_blank">Showing</a>},
      link_to_blank_unless_current("Showing", hash_for(order: :asc))
    assert_dom_equal %{<a href="http://www.example.com/?order=asc" target="_blank">Showing</a>},
      link_to_blank_unless_current("Showing", "http://www.example.com/?order=asc")

    @request = request_for_url("/?order=desc")
    assert_dom_equal %{<a href="/?order=desc&amp;page=2\" target="_blank">Showing</a>},
      link_to_blank_unless_current("Showing", hash_for(order: "desc", page: 2))
    assert_dom_equal %{<a href="http://www.example.com/?order=desc&amp;page=2" target="_blank">Showing</a>},
      link_to_blank_unless_current("Showing", "http://www.example.com/?order=desc&page=2")

    @request = request_for_url("/show")

    assert_dom_equal %{<a href="/" target="_blank">Listing</a>},
      link_to_blank_unless_current("Listing", url_hash)
    assert_dom_equal %{<a href="http://www.example.com/" target="_blank">Listing</a>},
      link_to_blank_unless_current("Listing", "http://www.example.com/")
  end

  private
    # MiniTest does not have build_message method, so I copy from below:
    # https://github.com/rails/rails/blob/master/actionpack/lib/action_dispatch/testing/assertions/dom.rb
    # Test::Unit
    # http://doc.ruby-lang.org/ja/1.9.3/method/Test=3a=3aUnit=3a=3aAssertions/i/build_message.html
    # Test::Unit (based on MiniTest)
    # http://www.ruby-doc.org/stdlib-2.0/libdoc/test/unit/rdoc/Test/Unit/Assertions.html#method-i-message
    def assert_dom_equal(expected, actual, message = "")
      expected_dom = HTML::Document.new(expected).root
      actual_dom   = HTML::Document.new(actual).root
      assert_equal expected_dom, actual_dom
    end
end
