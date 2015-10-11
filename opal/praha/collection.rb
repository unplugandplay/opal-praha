require 'active_support/core_ext/string'
module Praha
  module Collection

    def url(klass=nil) #url = nil)
      klass ||= self
      default_url = "http://#{$global.location.host}/#{klass.name.underscore}s"
      #url ? @url = url : (@url ? @url : @url = default_url)
    end

    def index!(&block)

      url, options = prepare_request
      HTTP.get(url, options) do |response|
        if response.ok?
          response.body.map { |json| self.load_json json }
          trigger :ajax_success, response
          trigger :refresh, self.all
        else
          trigger :ajax_error, response
        end
      end

      block.call(self.all) if block
    end

    def create!(payload, &block)

      before_create
      before_save
      url, options = prepare_request nil, {payload:payload}
      HTTP.post(url, options) do |response|
        if response.ok?

          record = self.load_json response.body
          record.did_create
          self.trigger :ajax_success, response
          self.trigger :change, record.class.all
        else
          self.trigger_events :ajax_error, response
        end
      end

      block.call(record) if block

      after_create
      after_save
    end


    def update!(record,payload, &block)

      before_update
      before_save
      url, options = prepare_request record, {payload:payload}
      HTTP.put(url, options) do |response|
        if response.ok?

          record = self.load_json response.body
          record.did_update

          self.trigger :ajax_success, response
          self.trigger :change, record.class.all
        else
          self.trigger_events :ajax_error, response
        end
      end

      block.call(record) if block

      after_update
      after_save
    end

    def delete!(record, &block)

      before_delete

      url, options = prepare_request record
      HTTP.delete(url, options) do |response|
        if response.ok?

          record.did_destroy
          trigger :ajax_success, response
          trigger :change, record.class.all
        else
          trigger :ajax_error, response
        end
      end

      block.call(record) if block

      after_save
    end



    def update_record(record, &block)
      url = record_url(record)
      options = {dataType: "json", payload: record.as_json}
      HTTP.put(url, options) do |response|
        if response.ok?
          record.class.load_json response.body
          record.class.trigger :ajax_success, response
          record.did_update
          record.class.trigger :change, record.class.all
        else
          record.trigger_events :ajax_error, response
        end
      end

      block.call(record) if block
    end


    def find(record, id)
      # TODO remote fetch
      nil
    end


    def prepare_request(record = nil, options = {})

      id = options.fetch(:id, nil) || (record.id if (record && record.respond_to?(:id))) #record.try.id 
      params = options.fetch(:params, nil)
      payload = options.fetch(:payload, nil)

      if record && record.is_a?(Model)
        record_url = (record.to_url if record.respond_to? :to_url) || Model.url(record.class)
        #record_url = record.url if record.respond_to? :url

        url = id ? "#{record_url}/#{id}" : record_url
      else
        url = self.url

        #raise "Model does not define REST url: #{record}"

      end

      options = {dataType: "json", data: params, payload: payload}

      [url, options]
    end

    def before_create
    end
    def before_update
    end
    def before_save
    end
    def before_delete
    end
    def after_create
    end
    def after_update
    end
    def after_save
    end
    def after_delete
    end
  end
end
