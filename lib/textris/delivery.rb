module Textris
  module Delivery
    module_function

    def get
      methods = Rails.application.config.try(:textris_delivery_method)
      methods = [*methods].compact
      if methods.blank?
        if Rails.env.development?
          methods = [:log]
        elsif Rails.env.test?
          methods = [:test]
        else
          methods = [:mail]
        end
      end

      methods.map do |method|
        "Textris::Delivery::#{method.to_s.camelize}".safe_constantize ||
          "#{method.to_s.camelize}Delivery".safe_constantize
      end.compact
    end
  end
end
