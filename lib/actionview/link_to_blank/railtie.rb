require 'actionview/link_to_blank/url_helper'

module Actionview
  module LinkToBlank
    class Railtie < Rails::Railtie
      initializer 'actionview.link_to_blank.url_helper' do |app|
        ActionView::Base.send :include, UrlHelper
      end
    end
  end
end
