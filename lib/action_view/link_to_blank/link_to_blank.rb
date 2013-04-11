module LinkToBlank
  module ::ActionView
    module Helpers
      module UrlHelper
        def link_to_blank(*args, &block)
          if block_given?
            options      = args.first || {}
            html_options = args.second || {}
            link_to_blank(capture(&block), options, html_options)
          else
            name         = args[0]
            options      = args[1] || {}
            html_options = args[2] || {}

            # override
            html_options.merge!(target: '_blank')

            link_to(name, options, html_options)
          end
        end
      end
    end
  end
end
