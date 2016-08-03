module Textris
  module Delivery
    class Twilio < Textris::Delivery::Base
      def deliver(to)
        client.account.messages.create(
          :from => phone_with_plus(message.from_phone),
          :to   => phone_with_plus(to),
          :body => message.content)
      end

      private

      # Twillo requires phone numbers starting with a '+' sign
      def phone_with_plus(phone)
        phone.to_s.start_with?('+') ? phone : "+#{phone}"
      end

      def client
        @client ||= ::Twilio::REST::Client.new
      end
    end
  end
end
