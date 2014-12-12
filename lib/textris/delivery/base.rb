module Textris
  module Delivery
    class Base
      class << self
        def send_message_to_all(message)
          message.to.each do |to|
            send_message(to, message)
          end
        end
      end
    end
  end
end
