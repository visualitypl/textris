module Textris
  module Delay
    module Sidekiq
      class Worker
        include ::Sidekiq::Worker

        def perform(texter, action, args)
          texter = texter.safe_constantize

          if texter.present?
            args = ::Textris::Delay::Sidekiq::Serializer.deserialize(args)

            texter.new(action, *args).call_action.deliver
          end
        end
      end
    end
  end
end
