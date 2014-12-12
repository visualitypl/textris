module Textris
  module Delivery
    module_function

    def get
      methods = Rails.application.config.try(:textris_delivery_method)
      methods = [*methods].compact
      if methods.blank?
        methods = [:test]
      end

      methods.map do |method|
        "Textris::Delivery::#{method.to_s.camelize}".safe_constantize ||
          "#{method.to_s.camelize}Delivery".safe_constantize
      end.compact
    end
  end
end
