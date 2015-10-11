require 'spec_helper'
require 'praha/template_view'

Template.new('template_view_spec') do |buf|
  buf.append "foo"
  buf.append "bar"
  buf.join
end

class TemplateViewSpec < Praha::TemplateView
  template :template_view_spec
end

class SimpleTemplate < Praha::TemplateView
end

class SimplerTemplateView < Praha::TemplateView
  class SubClassView < Praha::TemplateView
  end
end

describe Praha::TemplateView do
  before do
    @view = TemplateViewSpec.new
    @tmpl = Template['template_view_spec']
  end

  describe "#_render_template" do
    it "returns the rendered content for the template" do
      @view._render_template(@tmpl).should == "foobar"
    end
  end

  describe ".template" do
    it "returns the class name underscored when no name given" do
      SimpleTemplate.template.should == "simple_template"
    end

    it "removes the `View' prefix from class name" do
      SimplerTemplateView.template.should == "simpler_template"
    end

    it "removes any initial module names from class name" do
      SimplerTemplateView::SubClassView.template.should == "sub_class"
    end
  end
end
