module Textris
  module Delivery
    module_function

    def get
      case Rails.application.config.try(:textris_delivery_method).to_s
      when 'mail'
        ::Textris::Delivery::Mail
      when 'test'
        ::Textris::Delivery::Test
      else
        ::Textris::Delivery::Test
      end
    end
  end
end
