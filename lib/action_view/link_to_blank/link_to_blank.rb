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
            html_options.reverse_merge! target: '_blank'

            link_to(name, options, html_options)
          end
        end

        def link_to_blank_unless(condition, name, options = {}, html_options = {}, &block)
          if condition
            if block_given?
              block.arity <= 1 ? capture(name, &block) : capture(name, options, html_options, &block)
            else
              ERB::Util.html_escape(name)
            end
          else
            link_to_blank(name, options, html_options)
          end
        end

        def link_to_blank_if(condition, name, options = {}, html_options = {}, &block)
          link_to_blank_unless !condition, name, options, html_options, &block
        end

        def link_to_blank_unless_current(name, options = {}, html_options = {}, &block)
          link_to_blank_unless current_page?(options), name, options, html_options, &block
        end
      end
    end
  end
end
