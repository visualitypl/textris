module Textris
  module Delivery
    class Test < Textris::Delivery::Base
      class << self
        def deliveries
          @deliveries ||= []
        end
      end

      def deliver(to)
        self.class.deliveries.push(::Textris::Message.new(
          :content    => message.content,
          :from_name  => message.from_name,
          :from_phone => message.from_phone,
          :texter     => message.texter,
          :action     => message.action,
          :to         => to,
          :media_urls => message.media_urls))
      end
    end
  end
end
