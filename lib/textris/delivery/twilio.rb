module Textris
  module Delivery
    class Twilio < Textris::Delivery::Base
      def deliver(to)
        client.messages.create(
          :from => message.from_phone,
          :to   => to,
          :body => message.content)
      end

      private

      def client
        @client ||= ::Twilio::REST::Client.new
      end
    end
  end
end
