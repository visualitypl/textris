require 'action_controller'
require 'action_mailer'
require 'phony'

begin
  require 'sidekiq'
rescue LoadError
  require 'textris/delay/sidekiq/missing'
  Textris::Delay::Sidekiq.include(Textris::Delay::Sidekiq::Missing)
else
  require 'textris/delay/sidekiq'
end

require 'textris/base'
require 'textris/message'
require 'textris/delivery'
require 'textris/delivery/base'
require 'textris/delivery/test'
require 'textris/delivery/mail'
require 'textris/delivery/twilio'
