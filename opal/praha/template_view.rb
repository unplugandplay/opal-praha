require 'template'
require 'praha/view'
require 'praha/output_buffer'
require 'active_support/core_ext/string'

module Praha
  class TemplateView < View

    def self.action(name, method = undefined, &block)
    if `method === undefined && !#{block_given?}`
      raise ArgumentError, "tried to create a Proc object without a block"
    end

    block ||= case method
                when Proc
                  method
                when Method
                  method.to_proc
                when UnboundMethod
                  lambda do |*args|
                    bound = method.bind(self)
                    bound.call *args
                  end
                else
                  raise TypeError, "wrong argument type #{block.class} (expected Proc/Method)"
              end

    %x{
      var id = '$' + name;

      block.$$jsid = name;
      block.$$s    = null;
      block.$$def  = block;

      if (self.$$is_singleton) {
        self.$$proto[id] = block;
      }
      else {
        Opal.defn(self, id, block);
      }

      return name;
    }
    end

    def self.template(name = nil)
      if name
        @template = name
      elsif @template
        @template
      elsif name = self.name
        @template = name.sub(/View$/, '').demodulize.underscore
      end
    end

    def render
      before_render

      if template = Template[self.class.template]
        element.html = _render_template(template)
      end

      after_render
    end

    def partial(name)
      Template[name].render(self)
    end

    def _render_template(template)
      @output_buffer = OutputBuffer.new
      instance_exec @output_buffer, &template.body
    end

  end
end
