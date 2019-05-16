module Textris
  class Message
    attr_reader :content, :from_name, :from_phone, :to, :texter, :action, :args,
      :media_urls, :twilio_messaging_service_sid

    def initialize(options = {})
      initialize_content(options)
      initialize_author(options)
      initialize_recipients(options)

      @texter     = options[:texter]
      @action     = options[:action]
      @args       = options[:args]
      @media_urls = options[:media_urls]
    end

    def deliver
      deliveries = ::Textris::Delivery.get
      deliveries.each do |delivery|
        delivery.new(self).deliver_to_all
      end

      self
    end

    def texter(options = {})
      if options[:raw]
        @texter
      elsif @texter.present?
        @texter.to_s.split('::').last.to_s.sub(/Texter$/, '')
      end
    end

    def from
      if @from_phone.present?
        if @from_name.present?
          if PhoneFormatter.is_alphameric?(@from_phone)
            @from_phone
          else
            if PhoneFormatter.is_a_short_code?(@from_phone)
              "#{@from_name} <#{@from_phone}>"
            else
              "#{@from_name} <#{Phony.format(@from_phone)}>"
            end
          end
        else
          Phony.format(@from_phone)
        end
      elsif @from_name.present?
        @from_name
      end
    end

    def content
      @content ||= parse_content(@renderer.render_content)
    end

    private

    def initialize_content(options)
      if options[:content].present?
        @content  = parse_content options[:content]
      elsif options[:renderer].present?
        @renderer = options[:renderer]
      else
        raise(ArgumentError, "Content must be provided")
      end
    end

    def initialize_author(options)
      if options.has_key?(:twilio_messaging_service_sid)
        @twilio_messaging_service_sid = options[:twilio_messaging_service_sid]
      elsif options.has_key?(:from)
        @from_name, @from_phone = parse_from options[:from]
      else
        @from_name  = options[:from_name]
        @from_phone = options[:from_phone]
      end
    end

    def initialize_recipients(options)
      @to = parse_to options[:to]

      unless @to.present?
        raise(ArgumentError, "Recipients must be provided and E.164 compliant")
      end
    end

    def parse_from(from)
      parse_from_dual(from) || parse_from_singular(from)
    end

    def parse_from_dual(from)
      matches = from.match(/(.*)\<(.*)\>\s*$/)
      return unless matches
      name, sender_id = matches.captures
      return unless name && sender_id

      if Phony.plausible?(sender_id) || PhoneFormatter.is_a_short_code?(sender_id)
        [name.strip, Phony.normalize(sender_id)]
      elsif PhoneFormatter.is_alphameric?(sender_id)
        [name.strip, sender_id]
      end
    end

    def parse_from_singular(from)
      if Phony.plausible?(from)
        [nil, Phony.normalize(from)]
      elsif PhoneFormatter.is_a_short_code?(from)
        [nil, from.to_s]
      elsif from.present?
        [from.strip, nil]
      end
    end

    def parse_to(to)
      to = [*to]
      to = to.select { |phone| Phony.plausible?(phone.to_s) }
      to = to.map    { |phone| Phony.normalize(phone.to_s) }

      to
    end

    def parse_content(content)
      content = content.to_s
      content = content.rstrip

      content
    end
  end
end
