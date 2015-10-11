require 'opal'
require 'opal/parser'

module Praha::Eventize

  def self.generate(model)

    model.on :click, "[opal-click]" do |event|
      #p event
      activate event
    end

    model.on :dblclick, "[opal-dblclick]" do |event|
      activate event
    end

    model.on :focusin, "[opal-focusin]" do |event|
      activate event
    end

    model.on :focusout, "[opal-focusout]" do |event|
      activate event
    end

    model.on :hover, "[opal-hover]" do |event|
      activate event
    end

    model.on :keydown, "[opal-keydown]" do |event|
      activate event
    end

    model.on :keyup, "[opal-keyup]" do |event|
      activate event
    end

    model.on :keypress, "[opal-keypress]" do |event|
      activate event
    end


    model.on :keypress, "[opal-press-enter]" do |event|
      if event.which == 13
        activate event
      else
        p event.which
      end
    end

    model.on :load, "[opal-load]" do |event|
      activate event
    end

    model.on :mousedown, "[opal-mousedown]" do |event|
      activate event
    end

    model.on :mouseenter, "[opal-mouseenter]" do |event|
      activate event
    end

    model.on :mouseleave, "[opal-mouseleave]" do |event|
      activate event
    end

    model.on :mousemove, "[opal-mousemove]" do |event|
      activate event
    end

    model.on :mouseout, "[opal-mouseout]" do |event|
      activate event
    end

    model.on :mouseover, "[opal-mouseover]" do |event|
      activate event
    end

    model.on :mouseup, "[opal-mouseup]" do |event|
      activate event
    end

    model.on :ready, "[opal-ready]" do |event|
      activate event
    end

    model.on :resize, "[opal-resize]" do |event|
      activate event
    end

    model.on :scroll, "[opal-scroll]" do |event|
      activate event
    end

    model.on :select, "[opal-select]" do |event|
      activate event
    end

    model.on :submit, "[opal-submit]" do |event|
      activate event
    end

    model.on :unload, "[opal-unload]" do |event|
      activate event
    end
  end

  private

  def activate event

    element = event.target
    event_type = event.type
    event_type = "press_enter" if event_type=="keypress" && event.which == 13

    m_attr_name = m_id_name = m_class_name = m_short_name = nil

    attr_name = "opal-#{event_type.gsub("_", "-")}"
    p attr_name
    if element.attr(attr_name) != ""
      m_attr_name = element.attr("opal-#{event_type}")
      p m_attr_name
    end

    if (element.class_name != '')
      e_class_name = element.class_name.gsub("-", "_")
      m_short_name = e_class_name.split(' ')[0] if default_behaviour?(element,event_type)
      m_class_name = "#{event_type}.#{e_class_name.gsub(" ", ".")}"
    end

    if (element.id != '')
      e_id = element.id.gsub("-", "_")
      m_short_name = e_id if default_behaviour?(element,event_type)
      m_id_name = "#{event_type}##{e_id}"
    end

    [m_attr_name, m_id_name, m_class_name, m_short_name].each do |m_name|
      puts "testing #{m_name}"
      if self.methods.include?(m_name)
        puts "send opal-#{event_type}  ->  #{m_name}"
        self.send(m_name)
        event.stop_propagation
        return
      end
    end

    raise "unknown method(s):'#{[m_attr_name, m_id_name, m_class_name, m_short_name].compact.to_s}' for opal-#{event_type} in #{self.to_s} "
  end

  def default_behaviour?(el,ev_type)
    p "default_behaviour?"
    p el
    el_type = el.attr('type')
    p el_type
    p ev_type
    el_name = el.tag_name
    p el_name
    return true if ev_type == 'click' && (el_name=="button" || el_type=="checkbox" || el_type=="radio" || el_name=="div" || el_name=="li")

    return true if (ev_type == 'press_enter' || ev_type == 'focusout' ) && (el_type=="text" || (el_type==nil && el_name=="input" ))
    p "false"
    #return true if ev_type == 'click' && el_type=="button"
    false
  end

end
