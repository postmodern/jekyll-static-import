require 'spec_helper'
require 'jekyll/static/import'

describe Jekyll::Static::Import do
  it "should have a VERSION constant" do
    subject.const_get('VERSION').should_not be_empty
  end
end
