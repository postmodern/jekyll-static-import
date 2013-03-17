require 'spec_helper'
require 'jekyll/import/converter'

require 'nokogiri'

describe Converter do
  let(:content_xpath) { 'div.content' }

  subject { described_class.new(content_xpath) }

  describe "#initialize" do
    context "with defaults" do
      its(:layout)        { should == 'default' }
      its(:title_xpath)   { should == '//title' }
      its(:inline_xpaths) { should be_empty }
      its(:remove_xpaths) { should be_empty }
    end

    context "when :inline is a String" do
      let(:inline) { 'div.foo' }

      subject { described_class.new(content_xpath, :inline => inline) }

      its(:inline_xpaths) { should == [inline] }
    end

    context "when :inline is an Array" do
      let(:inline) { ['div.foo'] }

      subject { described_class.new(content_xpath, :inline => inline) }

      its(:inline_xpaths) { should == inline }
    end

    context "when :remove is a String" do
      let(:remove) { 'div.foo' }

      subject { described_class.new(content_xpath, :remove => remove) }

      its(:remove_xpaths) { should == [remove] }
    end

    context "when :remove is an Array" do
      let(:remove) { ['div.foo'] }

      subject { described_class.new(content_xpath, :remove => remove) }

      its(:remove_xpaths) { should == remove }
    end
  end

  let(:doc) do
    Nokogiri::HTML(%{
      <html>
        <head>
          <title>Foo - Bar</title>
        </head>

        <body>
          <div class="content">
            <h1>Title</h1>

            <p>foo <span class="bold">bar</span></p>

            <div id="extended">
            </div>
          </div>
        </body>
      </html>
    })
  end

  let(:title)        { doc.at('//title').inner_text }
  let(:content_node) { doc.at(content_xpath)        }

  describe "#title" do
    it "should return the title text" do
      subject.title(doc).should == title
    end
  end

  describe "#content" do
    it "should return the content node" do
      subject.content(doc).should == content_node
    end
  end

  describe "#sanitize" do
    context "when remove_xpaths is not empty" do
      subject do
        described_class.new(content_xpath,:remove => '#extended')
      end

      it "should remove the nodes" do
        subject.sanitize(content_node)
        
        content_node.at('#extended').should be_nil
      end
    end

    context "when inline_xpaths is not empty" do
      subject do
        described_class.new(content_xpath,:inline => 'span.bold')
      end

      it "should remove the nodes" do
        subject.sanitize(content_node)
        
        content_node.at('p').inner_text.should == 'foo bar'
      end
    end
  end

  describe "#convert" do
  end

  describe "#to_markdown" do
    subject do
      described_class.new(
        content_xpath,
        :remove => '#extended',
        :inline => 'span.bold'
      )
    end

    it "should convert the inner HTML to Markdown" do
      subject.markdown(doc).should == "# Title\n\nfoo bar\n\n"
    end

    context "when there is no content node" do
      let(:doc) do
        Nokogiri::HTML(%{
          <html>
            <body>
            </body>
          </html>
        })
      end

      it "should return an empty String" do
        subject.markdown(doc).should == ''
      end
    end
  end

  describe "#page" do
    subject do
      described_class.new(
        content_xpath,
        :remove => '#extended',
        :inline => 'span.bold'
      )
    end

    it "should generate the YAML front matter" do
      subject.page(doc).should start_with(%{
---
layout: default
title: "Foo - Bar"
---
      }.strip)
    end

    it "should append the markdown content of the HTML document" do
      subject.page(doc).should end_with(subject.markdown(doc))
    end

    context "when there is no title" do
      let(:doc) do
        Nokogiri::HTML(%{
          <html>
            <body>
              <div class="content">
                <h1>Title</h1>
    
                <p>foo <span class="bold">bar</span></p>
    
                <div id="extended">
                </div>
              </div>
            </body>
          </html>
        })
      end

      it "should omit the 'title:' attribute" do
        subject.page(doc).should_not include('title: ')
      end
    end
  end
end
