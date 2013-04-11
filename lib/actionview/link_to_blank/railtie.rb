module Actionview
  module LinkToBlank
    class Railtie < ::Rails::Railtie
      initializer 'actionview-link_to_blank' do |app|
        ActiveSupport.on_load(:action_view) do
          require 'actionview/link_to_blank/link_to_blank'
        end
      end
    end
  end
end
