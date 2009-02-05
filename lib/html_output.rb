module HtmlOutput
  module ActiveRecordHelper
    def self.included(base)
      base.module_eval do
        alias_method_chain :default_input_block, :html_output
      end
    end

    private
      def default_input_block_with_html_output
        Proc.new { |record, column| %(<p><label for="#{record}_#{column.name}">#{column.human_name}</label><br>#{input(record, column.name)}</p>) }
      end
  end

  module TagHelper
    def self.included(base)
      base.module_eval do
        alias_method_chain :tag, :html_output
      end
    end

    def tag_with_html_output(name, options = nil, open = false, escape = true)
      "<#{name}#{tag_options(options, escape) if options}>"
    end
  end

  module TextHelper
    def self.included(base)
      base.module_eval do
        alias_method_chain :simple_format, :html_output
      end
    end

    def simple_format_with_html_output(text, html_options = {})
      start_tag = tag('p', html_options, true)
      text = text.to_s.dup
      text.gsub!(/\r\n?/, "\n")                    # \r\n and \r -> \n
      text.gsub!(/\n\n+/, "</p>\n\n#{start_tag}")  # 2+ newline  -> paragraph
      text.gsub!(/([^\n]\n)(?=[^\n])/, '\1<br>')   # 1 newline   -> br
      text.insert 0, start_tag
      text << "</p>"
    end
  end
end

ActionView::Helpers::ActiveRecordHelper.send(:include, HtmlOutput::ActiveRecordHelper)
ActionView::Helpers::TagHelper.send(:include, HtmlOutput::TagHelper)
ActionView::Helpers::TextHelper.send(:include, HtmlOutput::TextHelper)
