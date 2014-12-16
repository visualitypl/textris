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
            ::Textris::Delay::Sidekiq::Worker.perform_in(@perform_in, *args)
          elsif @perform_at
            ::Textris::Delay::Sidekiq::Worker.perform_at(@perform_at, *args)
          else
            ::Textris::Delay::Sidekiq::Worker.perform_async(*args)
          end
        end
      end
    end
  end
end
