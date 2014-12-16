module Textris
  module Delay
    module Sidekiq
      class Worker
        include ::Sidekiq::Worker

        def perform(texter, action, params)
          texter = texter.safe_constantize

          if texter.present?
            texter.new(action, *params).call_action.deliver
          end
        end
      end

      class Proxy
        private

        def initialize(texter, options = {})
          @texter     = texter
          @perform_in = options[:perform_in]
          @perform_at = options[:perform_at]
        end

        def method_missing(method_name, *args)
          args = [@texter, method_name, args]

          if @perform_in
            ::Textris::Delay::Sidekiq::Worker.perform_in(@perform_in, *args)
          elsif @perform_at
            ::Textris::Delay::Sidekiq::Worker.perform_at(@perform_at, *args)
          else
            ::Textris::Delay::Sidekiq::Worker.perform_async(*args)
          end
        end
      end

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


