module Textris
  module Delivery
    class Nexmo < Textris::Delivery::Base
      def deliver(phone)
        client.send_message(
          from: message.from_phone,
          to:   phone,
          text: message.content
        )
      end

      private
        def client
          @client ||= ::Nexmo::Client.new
        end
    end
  end
end
