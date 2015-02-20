module Textris
  module Delay
    module ActiveJob
      def deliver_now
        deliver
      end

      def deliver_later(options = {})
        job = Textris::Delay::ActiveJob::Job

        [:wait, :wait_until, :queue].each do |option|
          if options.has_key?(option)
            job.set(option => options[option])
          end
        end

        job.perform_later(texter(:raw => true).to_s, action.to_s, args)
      end
    end
  end
end
