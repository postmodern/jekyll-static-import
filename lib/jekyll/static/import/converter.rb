require 'kramdown'

module Jekyll
  module Static
    module Import
      class Converter

        # The layout to use for each Jekyll page.
        #
        # @return [String]
        attr_reader :layout

        # XPath/CSS-path expression for the title node.
        #
        # @return [String]
        attr_reader :title_xpath

        # XPath/CSS-path expression for the content node.
        #
        # @return [String]
        attr_reader :content_xpath

        # List of XPath/CSS-path expressions for nodes to inline.
        #
        # @return [Array<String>]
        attr_reader :inline_xpaths

        # List of XPath/CSS-path expressions for nodes to remove.
        #
        # @return [Array<String>]
        attr_reader :remove_xpaths

        #
        # Initializes the Converter.
        #
        # @param [String] content_xpath
        #   The XPath/CSS-path expression for the content node.
        #
        # @param [Hash] options
        #   Additional options.
        #
        # @option options [String] :layout ('default')
        #   The layout to use for each Jekyll page.
        #
        # @option options [String] :title ('//title')
        #   The XPath/CSS-path expression for the title node.
        #
        # @option options [Array<String>, String] :inline
        #   List of XPath/CSS-path expressions for nodes to inline.
        #
        # @option options [Array<String>, String] :remove
        #   List of XPath/CSS-path expressions for nodes to remove.
        #
        def initialize(content_xpath,options={})
          @layout = options.fetch(:layout,'default')

          @title_xpath   = options.fetch(:title,'//title')
          @content_xpath = content_xpath

          @inline_xpaths = Array(options[:inline])
          @remove_xpaths = Array(options[:remove])
        end

        #
        # Extracts the title from the page.
        #
        # @param [Nokogiri::HTML::Document] doc
        #   The HTML document.
        #
        # @return [String, nil]
        #   
        def title(doc)
          if (title = doc.at(@title_xpath))
            title.inner_text
          end
        end

        #
        # Finds the HTML node containing the content.
        #
        # @param [Nokogiri::HTML::Document] doc
        #   The HTML document to convert.
        #
        # @return [Nokogiri::HTML::Node, nil]
        #   The HTML content node.
        #
        def content(doc)
          doc.at(@content_xpath)
        end

        #
        # Sanitizes the HTML node containing the content.
        #
        # @param [Nokogiri::HTML::Node] content_node
        #   The HTML node containing the content.
        #
        # @return [Nokogiri::HTML::Node]
        #   The sanitized node.
        #
        def sanitize(content_node)
          # remove all comments
          content_node.traverse do |node|
            node.remove if node.comment?
          end

          # remove additional nodes
          @remove_xpaths.each do |expr|
            content_node.search(expr).each do |node|
              node.remove
            end
          end

          # inline the text of various nodes
          @inline_xpaths.each do |expr|
            content_node.search(expr).each do |node|
              node.replace(node.inner_text)
            end
          end

          return content_node
        end

        #
        # Extracts and sanitizes the HTML content.
        #
        # @param [Nokogiri::HTML::Document] doc
        #   The HTML document to convert.
        #
        # @return [String]
        #   The raw HTML content.
        #
        def html(doc)
          if (content_node = content(doc))
            sanitize(content_node).inner_html
          else
            ''
          end
        end

        #
        # Converts the HTML content into a Markdown document.
        #
        # @param [Nokogiri::HTML::Document] doc
        #   The HTML document to convert.
        #
        # @return [Kramdown::Document]
        #   The Markdown document.
        #
        def kramdown(doc)
          Kramdown::Document.new(html(doc),:input => :html)
        end

        #
        # Converts HTML into Markdown.
        #
        # @param [Nokogiri::HTML::Document] doc
        #   The HTML document to convert.
        #
        # @return [String]
        #   The converted markdown.
        #
        def markdown(doc)
          kramdown(doc).to_kramdown
        end

        #
        # Converts HTML into a Jekyll page.
        #
        # @param [Nokogiri::HTML::Document] doc
        #   The HTML document to convert.
        #
        # @return [String]
        #   The converted Jekyll page.
        #
        def page(doc)
          title = title(doc)

          page = []
          page << '---'
          page << "layout: #{@layout}"
          page << "title: #{title.inspect}" if title
          page << '---'
          page << ''
          page << markdown(doc)

          return page.join($/)
        end

      end
    end
  end
end
