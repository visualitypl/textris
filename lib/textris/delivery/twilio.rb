require 'twilio-ruby'

module Textris
  module Delivery
    class Twilio < Textris::Delivery::Base
      class << self
        private

        def send_message(to, message)
          client.messages.create(
            :from => message.from_phone,
            :to   => to,
            :body => message.content)
        end

        def client
          @client ||= ::Twilio::REST::Client.new
        end
      end
    end
  end
end
