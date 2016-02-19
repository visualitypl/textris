module Textris
  module Delay
    module ActiveJob
      def deliver_now
        deliver
      end

      def deliver_later(options = {})
        job = Textris::Delay::ActiveJob::Job

        job.new(texter(:raw => true).to_s, action.to_s, args).enqueue(options)
      end
    end
  end
end
