module Textris
  module Utils
    # The Phony gem doesn't handle short codes. Short codes can be 5 or 6 digits
    # long. There are more restrictions on short codes, but this is a good
    # general start.
    def is_short_code?(phone_number)
      !!phone_number.to_s.match(/\A\d{5,6}\z/)
    end
  end
end
