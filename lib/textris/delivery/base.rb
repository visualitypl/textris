module Textris
  module Delivery
    class Base
      attr_reader :message

      def initialize(message)
        @message = message
      end

      def deliver_to_all
        message.to.each do |to|
          deliver(to)
        end
      end
    end
  end
end
