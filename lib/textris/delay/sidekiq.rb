module Textris
  module Delay
    module Sidekiq
      def delay
        ::Textris::Delay::Sidekiq::Proxy.new(self)
      end

      def delay_for(interval)
        unless interval.is_a?(Fixnum)
          raise(ArgumentError, "Proper interval must be provided")
        end

        ::Textris::Delay::Sidekiq::Proxy.new(self, :perform_in => interval)
      end

      def delay_until(timestamp)
        unless timestamp.respond_to?(:to_time)
          raise(ArgumentError, "Proper timestamp must be provided")
        end

        ::Textris::Delay::Sidekiq::Proxy.new(self, :perform_at => timestamp)
      end
    end
  end
end


