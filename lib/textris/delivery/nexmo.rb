module Textris
  module Delivery
    class Nexmo < Textris::Delivery::Base
      def deliver(phone)
        client.send_message(
          from: sender_id,
          to:   phone,
          text: message.content
        )
      end

      private
        def client
          @client ||= ::Nexmo::Client.new
        end

        def sender_id
          message.from_phone || message.from_name
        end
    end
  end
end
