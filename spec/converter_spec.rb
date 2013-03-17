require 'spec_helper'
require 'jekyll/import/converter'

require 'nokogiri'

describe Converter do
  let(:content_xpath) { 'div.content' }

  subject { described_class.new(content_xpath) }

  describe "#initialize" do
    context "with defaults" do
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
        <body>
          <div class="content">
            <p>foo <span class="bold">bar</span></p>

            <div id="extended">
            </div>
          </div>
        </body>
      </html>
    })
  end

  let(:content_node) { doc.at(content_xpath) }

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
end
