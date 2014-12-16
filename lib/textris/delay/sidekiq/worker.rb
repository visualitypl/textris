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
    end
  end
end
