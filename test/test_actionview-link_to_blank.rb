require 'minitest/autorun'
require 'active_support/concern'
require 'active_support/core_ext'
require 'action_view/helpers/capture_helper'
require 'action_view/helpers/url_helper'
require 'action_view/link_to_blank/link_to_blank'

class TestActionViewLinkToBlank < MiniTest::Unit::TestCase
  include ActionView::Helpers::UrlHelper

  def test_initialization
    [:link_to_blank].each do |method|
      assert_includes ActionView::Helpers::UrlHelper.instance_methods, method
    end
  end
end
