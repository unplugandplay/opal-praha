require 'praha/eventize'
require 'active_support/core_ext/string'
module Praha
  class View

    def self.eventize!
      include Praha::Eventize
      Praha::Eventize.generate(self)
    end

    def self.element(selector = nil)
      selector ? @element = selector : @element
    end

    def self.tag_name(tag = nil)
      define_method(:tag_name) { tag } if tag
    end

    def self.class_name(css_class = nil)
      define_method(:class_name) { css_class } if css_class
    end

    def self.events
      @events ||= []
    end


    def self.on(name, selector = nil, method = nil, &handler)
      handler = proc { |evt| __send__(method, evt) } if method
      events << [name, selector, handler]
    end

    attr_accessor :parent

    def element
      return @element if @element

      @element = create_element
      @element.add_class class_name
      setup_events

      @element
    end

    def observe(model)
      model.on(:load) { render }
      model.on(:save) { render }
      model.on(:update) { render }
      model.on(:destroy) { remove;render }
      model.on(:filter) { |filter| apply_filter filter }
    end

    def create_element
      scope = (self.parent ? parent.element : Element)

      if el = self.class.element
        scope.find el
      else
        e = scope.new tag_name
        e.add_class class_name
      end
    end


    def class_name
      ""
    end

    def tag_name
      "div"
    end

    def find(selector)
      element.find(selector)
    end

    def setup_events
      return @dom_events if @dom_events

      el = element
      @dom_events = self.class.events.map do |event|
        name, selector, handler = event
        wrapper = proc { |e| instance_exec(e, &handler) }

        el.on(name, selector, &wrapper)
        [name, selector, wrapper]
      end
    end

    def teardown_events
      el = element
      @dom_events.each do |event|
        name, selector, wrapper = event
        el.off(name, selector, &wrapper)
      end
    end


    # business codes

    def apply_filter(filter)
      element.toggle_class :hidden, hidden?(filter)
    end


    def remove
      element.remove
    end

    def add(model)
      model_klass_name = model.class.name
      model_name = model_klass_name.underscore # + pluralize ...
      klass = Object.const_get("#{model_klass_name}View")

      model_view = klass.new model
      model_view.render

      model_view_elements = self.instance_variable_get "@#{model_name}s"
      model_view_elements << model_view.element
    end

    #def destroy
    #  p self
    #  teardown_events
    #  remove
    #end


    # render

    def render
    end

    def before_render; end

    def after_render; end
  end
end

