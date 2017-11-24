module Textris
  class PhoneFormatter
    class << self
      def format(phone = '')
        return phone if is_a_short_code?(phone) || is_alphameric?(phone)
        "#{'+' unless phone.start_with?('+')}#{phone}"
      end

      # Short codes have more dependencies and limitations;
      # but this is a good general start
      def is_a_short_code?(phone)
        !!phone.to_s.match(/\A\d{4,6}\z/)
      end

      def is_a_phone_number?(phone)
        Phony.plausible?(phone)
      end

      # We ASSUME that if someone passes a value
      # that cannot be resolved as a short code or a phone
      # number, then it is Alphameric Sender ID
      def is_alphameric?(phone)
        !is_a_phone_number?(phone) && !is_a_short_code?(phone)
      end
    end
  end
end