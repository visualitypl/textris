module Textris
  module Delivery
    class Log < Textris::Delivery::Base
      AVAILABLE_LOG_LEVELS = %w{debug info warn error fatal unknown}

      def deliver(to)
        log :info,  "Sent text to #{Phony.format(to)}"
        log :debug, "Texter: #{message.texter || 'UnknownTexter'}" + "#" +
          "#{message.action || 'unknown_action'}"
        log :debug, "Date: #{Time.now}"
        log :debug, "From: #{message.from || 'unknown'}"
        log :debug, "To: #{message.to.map { |i| Phony.format(to) }.join(', ')}"
        log :debug, "Content: #{message.content}"
      end

      private

      def log(level, message)
        level = Rails.application.config.try(:textris_log_level) || level

        unless AVAILABLE_LOG_LEVELS.include?(level.to_s)
          raise(ArgumentError, "Wrong log level: #{level}")
        end

        Rails.logger.send(level, message)
      end
    end
  end
end
