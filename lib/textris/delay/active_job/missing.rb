module Textris
  module Delay
    module ActiveJob
      module Missing
        def active_job_missing(*args)
          raise(LoadError, "ActiveJob is required to delay sending messages")
        end

        alias_method :deliver_now,   :active_job_missing
        alias_method :deliver_later, :active_job_missing
      end
    end
  end
end
