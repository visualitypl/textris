require 'textris/utils'

module Textris
  module Delivery
    class Twilio < Textris::Delivery::Base
      include Textris::Utils

      def deliver(to)
        options = {
          :from => phone_with_plus(message.from_phone),
          :to   => phone_with_plus(to),
          :body => message.content
        }
        if message.media_urls.is_a?(Array)
          options[:media_url] = message.media_urls
        end
        client.messages.create(options)
      end

      private

      # Twillo requires phone numbers starting with a '+' sign
      def phone_with_plus(phone)
        return phone if is_short_code?(phone)
        phone.to_s.start_with?('+') ? phone : "+#{phone}"
      end

      def client
        @client ||= ::Twilio::REST::Client.new
      end
    end
  end
end
