require 'minitest/autorun'
require 'active_support/concern'
require 'active_support/core_ext'
require 'active_support/testing/deprecation'
require 'action_view'
require 'action_view/link_to_blank/link_to_blank'
require 'action_dispatch'

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

class TestActionViewLinkToBlank < MiniTest::Unit::TestCase

  # In a few cases, the helper proxies to 'controller'
  # or request.
  #
  # In those cases, we'll set up a simple mock
  attr_accessor :controller, :request

  routes = ActionDispatch::Routing::RouteSet.new
  routes.draw do
    get "/" => "foo#bar"
    get "/other" => "foo#other"
    get "/article/:id" => "foo#article", :as => :article
  end

  include ActionView::Helpers::UrlHelper
  include routes.url_helpers

  include ActionDispatch::Assertions::DomAssertions
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
    skip('Not deprecate in Rails3.2') if ActionPack::VERSION::MAJOR == 3
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
    skip('Not deprecate in Rails3.2') if ActionPack::VERSION::MAJOR == 3
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
    skip('Not deprecate in Rails3.2') if ActionPack::VERSION::MAJOR == 3
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

  def test_link_tag_using_block_in_erb
    out = render_erb %{<%= link_to('/') do %>Example site<% end %>}
    assert_equal '<a href="/">Example site</a>', out
  end

=begin
  def test_link_tag_with_html_safe_string
    assert_dom_equal(
      %{<a href="/article/Gerd_M%C3%BCller">Gerd M端ller</a>},
      link_to("Gerd M端ller", article_path("Gerd_M端ller".html_safe))
    )
  end

  def test_link_tag_escapes_content
    assert_dom_equal %{<a href="/">Malicious &lt;script&gt;content&lt;/script&gt;</a>},
      link_to("Malicious <script>content</script>", "/")
  end

  def test_link_tag_does_not_escape_html_safe_content
    assert_dom_equal %{<a href="/">Malicious <script>content</script></a>},
      link_to("Malicious <script>content</script>".html_safe, "/")
  end
=end

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
