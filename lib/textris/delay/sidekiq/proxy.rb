module Textris
  module Delay
    module Sidekiq
      class Proxy
        def initialize(texter, options = {})
          @texter     = texter
          @perform_in = options[:perform_in]
          @perform_at = options[:perform_at]
        end

        def method_missing(method_name, *args)
          args = ::Textris::Delay::Sidekiq::Serializer.serialize(args)
          args = [@texter, method_name, args]

          if @perform_in
            worker.perform_in(@perform_in, *args)
          elsif @perform_at
            worker.perform_at(@perform_at, *args)
          else
            worker.perform_async(*args)
          end
        end

        private

        def worker
          ::Textris::Delay::Sidekiq::Worker.set(queue: Configuration.default_queue)
        end
      end
    end
  end
end
