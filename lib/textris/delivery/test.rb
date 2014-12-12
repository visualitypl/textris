module Textris
  module Delivery
    class Test
      class << self
        def send_message_to_all(message)
          message.to.each do |to|
            send_message(to, message)
          end
        end

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
