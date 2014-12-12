module Textris
  module Delivery
    class Test < Textris::Delivery::Base
      class << self
        def messages
          @messages ||= []
        end

        private

        def send_message(to, message)
          messages.push(::Textris::Message.new(
            :content    => message.content,
            :from_name  => message.from_name,
            :from_phone => message.from_phone,
            :texter     => message.texter,
            :action     => message.action,
            :to         => to))
        end
      end
    end
  end
end
