module Textris
  module Delay
    module Sidekiq
      module Missing
        def sidekiq_missing(*args)
          raise(LoadError, "Sidekiq is required to delay sending messages")
        end

        alias_method :delay,       :sidekiq_missing
        alias_method :delay_for,   :sidekiq_missing
        alias_method :delay_until, :sidekiq_missing
      end
    end
  end
end
