module Textris
  module Delivery
    class Mail < Textris::Delivery::Base
      class Mailer < ActionMailer::Base
        def notify(from, to, subject, body)
          mail :from => from, :to => to, :subject => subject, :body => body
        end
      end

      def deliver(to)
        template_vars = { :to_phone => to }

        from    = apply_template from_template,    template_vars
        to      = apply_template to_template,      template_vars
        subject = apply_template subject_template, template_vars
        body    = apply_template body_template,    template_vars

        ::Textris::Delivery::Mail::Mailer.notify(
          from, to, subject, body).deliver
      end

      private

      def from_template
        Rails.application.config.try(:textris_mail_from_template) ||
          "#{from_format}@%{env:d}.%{app:d}.com"
      end

      def from_format
        if message.twilio_messaging_service_sid
          '%{twilio_messaging_service_sid}'
        else
          '%{from_name:d}-%{from_phone}'
        end
      end

      def to_template
        Rails.application.config.try(:textris_mail_to_template) ||
          "%{app:d}-%{env:d}-%{to_phone}-texts@mailinator.com"
      end

      def subject_template
        Rails.application.config.try(:textris_mail_subject_template) ||
          "%{texter:dh} texter: %{action:h}"
      end

      def body_template
        Rails.application.config.try(:textris_mail_body_template) ||
          "%{content}"
      end

      def apply_template(template, variables)
        template.gsub(/\%\{[a-z_:]+\}/) do |match|
          directive = match.gsub(/[%{}]/, '')
          key       = directive.split(':').first
          modifiers = directive.split(':')[1] || ''

          content = get_template_interpolation(key, variables)
          content = apply_template_modifiers(content, modifiers.chars)
          content = 'unknown' unless content.present?

          content
        end
      end

      def get_template_interpolation(key, variables)
        case key
        when 'app', 'env'
          get_rails_variable(key)
        when 'texter', 'action', 'from_name', 'from_phone', 'content', 'twilio_messaging_service_sid'
          message.send(key)
        when 'media_urls'
          message.media_urls.join(', ')
        else
          variables[key.to_sym]
        end.to_s.strip
      end

      def get_rails_variable(var)
        case var
        when 'app'
          Rails.application.class.module_parent_name
        when 'env'
          Rails.env
        end
      end

      def apply_template_modifiers(content, modifiers)
        modifiers.each do |modifier|
          case modifier
          when 'd'
            content = content.underscore.dasherize
          when 'h'
            content = content.humanize.gsub(/[-_]/, ' ')
          when 'p'
            content = Phony.format(content) rescue content
          end
        end

        content
      end
    end
  end
end
