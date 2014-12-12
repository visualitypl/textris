# textris

[![Build Status](https://travis-ci.org/visualitypl/textris.svg)](https://travis-ci.org/visualitypl/textris)
[![Code Climate](https://codeclimate.com/github/visualitypl/textris/badges/gpa.svg)](https://codeclimate.com/github/visualitypl/textris)

Simple gem for implementing texter classes which allow sending SMS messages in similar way to how e-mails are implemented and sent with ActionMailer-based mailers.

Unlike similar gems, **textris** has some unique features:

- e-mail proxy allowing to inspect messages using [Mailinator](https://mailinator.com/) or similar service
- phone number E164 validation and normalization with the [phony](https://github.com/floere/phony) gem
- multiple, per-environment configurable and chainable delivery methods
- built-in support for the Twilio API thanks to the [twilio-ruby](https://github.com/twilio/twilio-ruby) gem
- extensible with any number of custom delivery methods (also chainable)
- support for testing using self-explanatory `Textris::Base.deliveries`
- simple, extensible code written from the ground up instead of copying *ActionMailer*

## Installation

Add to `Gemfile`:

```ruby
gem 'textris'
```

And run:

    bundle install

## Usage

Place texter classes in `app/texters` (e.g. `app/texters/user_texter.rb`):

```ruby
class UserTexter < Textris::Base
  default :from => "Our Team <+48 666-777-888>"

  def welcome(user)
    @user = user

    text :to => @user.phone
  end
end
```

Place relevant view templates in `app/views/<texter_name>/<action_name>.text.*` (e.g. `app/views/user_texter/welcome.text.erb`):

```erb
Welcome to our system, <%= @user.name %>!
```

Invoke them from application logic:

```ruby
class User < ActiveRecord::Base
  after_create do
    UserTexter.welcome(self).deliver
  end
end
```

### Twilio

In order to use Twilio with **textris**, you must pre-configure the *twilio-ruby* settings. Create the `config/initializers/twilio.rb`:

```ruby
Twilio.configure do |config|
  config.account_sid = 'some_sid'
  config.auth_token  = 'some_auth_token'
end
```

> Unless otherwise [configured](#configuration), *Twilio* will be the default delivery method in `development` and `production` environment, while the *test* method will be used in (surprise, surprise) `test` environment by default.

### Custom delivery methods

Currently, **textris** comes with `twilio`, `test` and `mail` delivery methods built-in, but you can easily implement your own. Place desired delivery class in `app/deliveries/<name>_delivery.rb` (e.g. `app/deliveries/my_provider_delivery.rb`):

```ruby
class MyProviderDelivery < Textris::Delivery::Base
  # Implement sending message to single phone number
  def self.send_message(phone, message)
    some_send_method(:phone => phone, :text => message.content)
  end

  # ...or implement sending message to multiple phone numbers at once
  def self.send_message_to_all(message)
    other_send_method(:phone_array => message.to, :text => message.content)
  end
end
```

Only one of methods above must be implemented for the delivery class to work. In case of multiple phone numbers and no implementation of *send_message_to_all*, the *send_message* method will be invoked multiple times.

> You can place your custom deliveries in `app/texters` instead of `app/deliveries` if you don't want to clutter the *app* directory too much.

After implementing your own deliveries, you can activate them by setting app configuration:

```ruby
# Use your new delivery
config.textris_delivery_method = :my_provider

# Chain your new delivery with others, including stock ones
config.textris_delivery_method = [:my_provider, :twilio, :mail]
```

## Testing

Access all messages that were sent with the `:test` delivery:

```ruby
Textris::Base.deliveries
```

You may want to clear the delivery queue before each test:

```ruby
before(:each) do
  Textris::Base.deliveries.clear
end
```

Keep in mind that messages targeting multiple phone numbers, like:

```ruby
text :to => ['48111222333', '48222333444']
```

will yield multiple message deliveries, each for specific phone number.

## Configuration

You can change default settings by placing them in any of environment files, like `development.rb` or `test.rb`, or setting them globally in `application.rb`.

### Choosing and chaining delivery methods

```ruby
# Send messages via the Twilio REST API using the twilio-ruby gem
config.textris_delivery_method = :twilio

# Don't send anything, access your messages via Textris::Base.deliveries
config.textris_delivery_method = :test

# Send e-mails instead of SMSes in order to inspect their content
config.textris_delivery_method = :mail

# Chain multiple delivery methods (e.g. to have e-mail backups of your messages)
config.textris_delivery_method = [:mail, :test]
```

### Configuring the mail delivery

**textris** comes with reasonable defaults for the `mail` delivery method. It will send messages to a Mailinator address specific to the application name, environment and target phone number. You can customize the mail delivery by setting appropriate templates presented below.

> Arguably, the *textris_mail_to_template* setting is the most important here as it specifies the target e-mail address scheme.

```ruby
# E-mail target, here: "app-name-test-48111222333-texts@mailinator.com"
config.textris_mail_to_template = '%{app:d}-%{env:d}-%{to_phone}-texts@mailinator.com'

# E-mail sender, here: "our-team-48666777888@test.app-name.com"
config.textris_mail_from_template = '%{from_name:d}-%{from_phone}@%{env:d}.%{app:d}.com'

# E-mail subject, here: "User texter: Welcome"
config.textris_mail_subject_template = '%{texter:dh} texter: %{action:h}'

# E-mail body, here: "Welcome to our system, Mr Jones!"
config.textris_mail_body_template = '%{content}'
```

### Template interpolation

You can use the following interpolations in your mail templates:

- `app`: application name (like `AppName`)
- `env`: enviroment name (like `test` or `production`)
- `texter`: texter name (like `User`)
- `action`: action name (like `welcome`)
- `from_name`: name of the sender (like `Our Team`)
- `from_phone`: phone number of the sender (like `48666777888`)
- `to_phone`: phone number of the recipient (like `48111222333`)
- `content`: message content (like `Welcome to our system, Mr Jones!`)

You can add optional interpolation modifiers using the `%{variable:modifiers}` syntax. These are most useful for making names e-mail friendly. The following modifiers are available:

- `d`: dasherize (for instance, `AppName` becomes `app-name`)
- `h`: humanize (for instance, `user_name` becomes `User name`)
- `p`: format phone (for instance, `48111222333` becomes `+48 111 222 333`)

## Contributing

1. Fork it (https://github.com/visualitypl/codegrade/fork)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
