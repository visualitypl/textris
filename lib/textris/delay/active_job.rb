module Textris
  module Delay
    module ActiveJob
      def deliver_now
        deliver
      end

      def deliver_later(options = {})
        job = Textris::Delay::ActiveJob::Job

        job.new(texter(:raw => true).to_s, action.to_s, args)
          .enqueue(options.with_defaults(default_options))
      end

      def default_options
        { queue: Configuration.default_queue }
      end
    end
  end
end
