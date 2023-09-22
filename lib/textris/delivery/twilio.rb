module Textris
  module Delivery
    class Twilio < Textris::Delivery::Base
      def deliver(to)
        options = {
          :to   => PhoneFormatter.format(to),
          :body => message.content
        }

        if message.twilio_messaging_service_sid
          options[:messaging_service_sid] = message.twilio_messaging_service_sid
        else
          options[:from] = PhoneFormatter.format(message.from_phone)
        end

        if message.media_urls.is_a?(Array)
          options[:media_url] = message.media_urls
        end

        client.messages.create(**options)
      end

      private

      def client
        @client ||= ::Twilio::REST::Client.new
      end
    end
  end
end
