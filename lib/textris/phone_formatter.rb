module Textris
  class PhoneFormatter
    class << self
      def format(phone = '')
        return phone if is_a_short_code?(phone) || is_alphameric?(phone) || phone.nil?
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

      def is_alphameric?(phone)
        # \A               # Start of the string
        # (?=.*[a-zA-Z])   # Lookahead to ensure there is at least one letter in the entire string
        # [a-zA-z\d]{1,11} # Between 1 and 11 characters in the string
        # \z               # End of the string
        !!phone.to_s.match(/\A(?=.*[a-zA-Z])[a-zA-z\d]{1,11}\z/)
      end
    end
  end
end