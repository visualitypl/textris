module Textris
  module Delivery
    class Twilio < Textris::Delivery::Base
      def deliver(to)
        options = {
          :from => PhoneFormatter.format(message.from_phone),
          :to   => PhoneFormatter.format(to),
          :body => message.content
        }
        if message.media_urls.is_a?(Array)
          options[:media_url] = message.media_urls
        end
        client.messages.create(options)
      end

      private

      def client
        @client ||= ::Twilio::REST::Client.new
      end
    end
  end
end
