module Textris
  class Message
    attr_reader :content, :from_name, :from_phone, :to, :texter, :action

    def initialize(options = {})
      @to      = parse_to      options[:to]
      @content = parse_content options[:content]

      if options.has_key?(:from)
        @from_name, @from_phone = parse_from options[:from]
      else
        @from_name  = options[:from_name]
        @from_phone = options[:from_phone]
      end

      unless @content.present?
        raise(ArgumentError, "Content must be provided")
      end

      unless @to.present?
        raise(ArgumentError, "Recipients must be provided and E.164 compilant")
      end

      @texter = options[:texter]
      @action = options[:action]
    end

    def deliver
      deliveries = ::Textris::Delivery.get
      deliveries.each do |delivery|
        delivery.new(self).deliver_to_all
      end

      self
    end

    def texter
      if @texter.present?
        @texter.to_s.split('::').last.to_s.sub(/Texter$/, '')
      end
    end

    def from
      if @from_phone.present?
        if @from_name.present?
          "#{@from_name} <#{Phony.format(@from_phone)}>"
        else
          Phony.format(@from_phone)
        end
      elsif @from_name.present?
        @from_name
      end
    end

    private

    def parse_from(from)
      parse_from_dual(from) || parse_from_singular(from)
    end

    def parse_from_dual(from)
      if (matches = from.to_s.match(/(.*)\<(.*)\>\s*$/).to_a).size == 3 &&
          Phony.plausible?(matches[2])
        [matches[1].strip, Phony.normalize(matches[2])]
      end
    end

    def parse_from_singular(from)
      if Phony.plausible?(from)
        [nil, Phony.normalize(from)]
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
      content = content.gsub(/\s{1,}/, ' ')
      content = content.strip

      content
    end
  end
end
