# Textris

Simple gem for implementing texter classes which allow sending SMS messages in similar way to how e-mails are implemented and sent with ActionMailer-based mailers.

Unlike similar gems, **Textris** has some unique features:

- e-mail proxy allowing to inspect messages using [Mailinator](https://mailinator.com/) or similar service
- phone number E164 validation and normalization with the [Phony](https://github.com/floere/phony) gem
- multiple, per-environment configurable and chainable delivery methods
- extensible with any number of custom delivery methods (also chainable)
- support for testing using self-explanatory `Textris::Base.deliveries`
- simple, extensible code written from the ground up instead of copying *ActionMailer*

Currently, this gem comes with `test` and `mail` delivery methods, so there's no method for any real SMS gateway yet. Still, you can easily implement your own - see the [Custom delivery methods](#custom-delivery-methods) chapter below.

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

### Custom delivery methods

Place desired delivery method in `app/deliveries/<name>_delivery.rb` (e.g. `app/deliveries/my_provider_delivery.rb`):

```ruby
class MyProviderDelivery < Textris::Delivery::Base
  # Implement sending message to single phone number
  self.send_message(phone, message)
    some_send_method(:phone => phone, :text => message.content)
  end

  # ...or implement sending message to multiple phone numbers at once
  self.send_message_to_all(message)
    other_send_method(:phone_array => message.to, :text => message.content)
  end
end
```

> **NOTE**: You can also place your custom deliveries in `app/texters` if you don't want to clutter the *app* directory too much.

Only one of methods above must be implemented for the delivery class to work. In case of multiple phone numbers and no implementation of *send_message_to_all*, the *send_message* method will be invoked multiple times.

After implementing your own deliveries, you can activate them by setting app configuration:

```ruby
# Use your new delivery
config.textris_delivery_method = :my_provider

# Chain your new delivery with others, including stock ones
config.textris_delivery_method = [:my_provider, :mail]
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

Choose the delivery method:

```ruby
# Don't send anything, access your messages via Textris::Base.deliveries
config.textris_delivery_method = :test

# Send e-mails instead of SMSes in order to inspect their content
config.textris_delivery_method = :mail

# Chain multiple delivery methods (e.g. to have e-mail backups of your messages)
config.textris_delivery_method = [:mail, :test]
```

Configure the mail delivery with custom templates:

```ruby
# E-mail sender, here: "our-team-48666777888@test.app-name.com"
config.textris_mail_from_template = '%{from_name:d}-%{from_phone}@%{env:d}.%{app:d}.com'

# E-mail target, here: "app-name-test-48111222333-texts@mailinator.com"
config.textris_mail_to_template = '%{app:d}-%{env:d}-%{to_phone}-texts@mailinator.com'

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
