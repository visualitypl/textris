# textris

[![Gem Version](https://img.shields.io/gem/v/textris.svg?style=flat-square&label=version)](https://rubygems.org/gems/textris)
[![Downloads](https://img.shields.io/gem/dt/textris.svg?style=flat-square)](https://rubygems.org/gems/textris)
[![Build Status](https://img.shields.io/travis/visualitypl/textris/master.svg?style=flat-square&label=build)](https://travis-ci.org/visualitypl/textris)
[![Scrutinizer Code Quality](https://img.shields.io/scrutinizer/g/visualitypl/textris.svg?style=flat-square)](https://scrutinizer-ci.com/g/visualitypl/textris/?branch=master)
[![Code Climate](https://img.shields.io/codeclimate/github/visualitypl/textris.svg?style=flat-square)](https://codeclimate.com/github/visualitypl/textris)
[![Test Coverage](https://img.shields.io/codeclimate/coverage/github/visualitypl/textris.svg?style=flat-square)](https://codeclimate.com/github/visualitypl/textris)

Simple gem for implementing texter classes which allow sending SMS messages in similar way to how e-mails are implemented and sent with ActionMailer-based mailers.

Unlike similar gems, **textris** has some unique features:

- e-mail proxy allowing to inspect messages using [Mailinator](https://mailinator.com/) or similar service
- phone number E164 validation and normalization with the [phony](https://github.com/floere/phony) gem
- built-in support for the Twilio and Nexmo APIs with [twilio-ruby](https://github.com/twilio/twilio-ruby) and [nexmo](https://github.com/timcraft/nexmo) gems
- multiple, per-environment configurable and chainable delivery methods
- extensible with any number of custom delivery methods (also chainable)
- background and scheduled texting for Rails 4.2+ thanks to integration with [ActiveJob](http://edgeguides.rubyonrails.org/active_job_basics.html)
- scheduled texting for Rails 4.1 and older thanks to integration with the [sidekiq](https://github.com/mperham/sidekiq) gem
- support for testing using self-explanatory `Textris::Base.deliveries`
- simple, extensible, fully tested code written from the ground up instead of copying *ActionMailer*

See the [blog entry](http://www.visuality.pl/posts/txt-messaging-with-textris-gem) for the whole story and a practical usage example.

## Installation

Add to `Gemfile`:

```ruby
gem 'textris'
```

Then run:

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

### MMS

Media messages are supported if you are using the [Twilio](#twilio), [Log](#log) or [Mail](#configuring-the-mail-delivery) adapter. [Twilio currently supports sending MMS in the US and Canada](https://support.twilio.com/hc/en-us/articles/223181608-Can-I-send-or-receive-MMS-messages-).

Media messages aren't part of a template, but must be specified as an array of URLs when sending the message, like:

```ruby
class UserMediaTexter < Textris::Base
  default :from => "Our Team <+48 666-777-888>"

  def welcome(user)
    @user = user

    text(
      :to         => @user.phone,
      :media_urls => ["http://example.com/hilarious.gif"]
    )
  end
end
```

### Background and scheduled

#### ActiveJob integration

As of version 0.4, **textris** supports native Rails 4.2+ way of background job handling, the [ActiveJob](http://edgeguides.rubyonrails.org/active_job_basics.html). You can delay delivery of your texters the same way as with ActionMailer mailers, like:

```ruby
UserTexter.welcome(user).deliver_later
UserTexter.welcome(user).deliver_later(:wait => 1.hour)
UserTexter.welcome(user).deliver_later(:wait_until => 1.day.from_now)
UserTexter.welcome(user).deliver_later(:queue => :custom_queue)
UserTexter.welcome(user).deliver_now
```

> You can safely pass ActiveRecord records as delayed action arguments. ActiveJob uses [GlobalID](https://github.com/rails/activemodel-globalid/) to serialize them for scheduled delivery.

By default, `textris` queue will be used by the *Textris::Delay::ActiveJob::Job* job.

#### Direct Sidekiq integration

> As of Rails 4.2, ActiveJob is the recommended way for background job handling and it does support Sidekiq as its backend, so please see [chapter above](#activejob-integration) if you're using Rails 4.2 or above. Otherwise, keep on reading to use textris with Sidekiq regardless of your Rails version.

Thanks to Sidekiq integration, you can send text messages in the background to speed things up, retry in case of failures or just to do it at specific time. To do so, use one of three delay methods:

```ruby
UserTexter.delay.welcome(user)
UserTexter.delay_for(1.hour).welcome(user)
UserTexter.delay_until(1.day.from_now).welcome(user)
```

Remember not to call `deliver` after the action invocation when using delay. It will be called by the *Textris::Delay::Sidekiq::Worker* worker.

> You can safely pass ActiveRecord records and arrays as delayed action arguments. **textris** will store their `id`s and find them upon scheduled delivery.

Keep in mind that **textris** does not install *sidekiq* for you. If you don't have it yet, [install Redis](http://redis.io/topics/quickstart) on your machine and add the *sidekiq* gem to `Gemfile`:

```ruby
gem 'sidekiq'
```

Then run:

    bundle install
    bundle exec sidekiq

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

Below you'll find sample settings for any of supported delivery methods along with short description of each:

```ruby
# Send messages via the Twilio REST API
config.textris_delivery_method = :twilio

# Send messages via the Nexmo API
config.textris_delivery_method = :nexmo

# Don't send anything, log messages into Rails logger
config.textris_delivery_method = :log

# Don't send anything, access your messages via Textris::Base.deliveries
config.textris_delivery_method = :test

# Send e-mails instead of SMSes in order to inspect their content
config.textris_delivery_method = :mail

# Chain multiple delivery methods (e.g. to have e-mail and log backups of messages)
config.textris_delivery_method = [:twilio, :mail, :log]
```

> Unless otherwise configured, default delivery methods will be: *log* in `development` environment, *test* in `test` environment and *mail* in `production` environment. All these come with reasonable defaults and will work with no further configuration.

#### Twilio

**textris** connects with the Twilio API using *twilio-ruby* gem. It does not, however, install the gem for you. If you don't have it yet, add the *twilio-ruby* gem to `Gemfile`:

```ruby
gem 'twilio-ruby'
```

Then, pre-configure the *twilio-ruby* settings by creating the `config/initializers/twilio.rb` file:

```ruby
Twilio.configure do |config|
  config.account_sid = 'some_sid'
  config.auth_token  = 'some_auth_token'
end
```

To use Twilio's Copilot use `twilio_messaging_service_sid` in place of `from` when sending a text or setting defaults.

#### Nexmo

In order to use Nexmo with **textris**, you need to include the `nexmo` gem in your `Gemfile`:

```ruby
gem 'nexmo', '~> 4'
```

The Nexmo gem uses the environment variables `NEXMO_API_KEY` and `NEXMO_API_SECRET` to authenticate with the API.
Therefore the safest way to provide authentication credentials is to set these variables in your application environment.

#### Log

**textris** logger has similar logging behavior to ActionMailer. It will log single line to *info* log with production in mind and then a couple details to *debug* log. You can change the log level for the whole output:

```ruby
config.textris_log_level = :info
```

#### Custom delivery methods

Currently, **textris** comes with several delivery methods built-in, but you can easily implement your own. Place desired delivery class in `app/deliveries/<name>_delivery.rb` (e.g. `app/deliveries/my_provider_delivery.rb`):

```ruby
class MyProviderDelivery < Textris::Delivery::Base
  # Implement sending message to single phone number
  def deliver(phone)
    send_sms(:phone => phone, :text => message.content)
  end

  # ...or implement sending message to multiple phone numbers at once
  def deliver_to_all
    send_multiple_sms(:phone_array => message.to, :text => message.content)
  end
end
```

Only one of methods above must be implemented for the delivery class to work. In case of multiple phone numbers and no implementation of *deliver_to_all*, the *deliver* method will be invoked multiple times.

> You can place your custom deliveries in `app/texters` or `app/models` instead of `app/deliveries` if you don't want to clutter the *app* directory too much.

After implementing your own deliveries, you can activate them by setting app configuration:

```ruby
# Use your new delivery
config.textris_delivery_method = :my_provider

# Chain your new delivery with others, including stock ones
config.textris_delivery_method = [:my_provider, :twilio, :mail]
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

#### Template interpolation

You can use the following interpolations in your mail templates:

- `%{app}`: application name (e.g. `AppName`)
- `%{env}`: enviroment name (e.g. `test` or `production`)
- `%{texter}`: texter name (e.g. `User`)
- `%{action}`: action name (e.g. `welcome`)
- `%{from_name}`: name of the sender (e.g. `Our Team`)
- `%{from_phone}`: phone number of the sender (e.g. `48666777888`)
- `%{to_phone}`: phone number of the recipient (e.g. `48111222333`)
- `%{content}`: message content (e.g. `Welcome to our system, Mr Jones!`)
- `%{media_urls}`: comma separated string of media URLs (e.g. `http://example.com/hilarious.gif`)

You can add optional interpolation modifiers using the `%{variable:modifiers}` syntax. These are most useful for making names e-mail friendly. The following modifiers are available:

- `d`: dasherize (for instance, `AppName` becomes `app-name`)
- `h`: humanize (for instance, `user_name` becomes `User name`)
- `p`: format phone (for instance, `48111222333` becomes `+48 111 222 333`)

### URL Defaults

Textris uses `ActionController::Renderer` behind the scenes. Add or modify `config/initializers/application_controller_renderer.rb` in your Rails to change the default settings:

```
# Be sure to restart your server when you modify this file.

ActiveSupport::Reloader.to_prepare do
  ApplicationController.renderer.defaults.merge!(
    http_host: ENV['CANONICAL_HOST'], # or ActionMailer::Base.default_url_options[:host] to use the same host as ActionMailer
    https: Rails.env.production?
  )
end
```

## Example project

[Here](https://github.com/visualitypl/textris/tree/master/example/rails-4.2) you can find a simple example project that demonstrates **textris** usage with Rails 4.2. In order to see how it works or experiment with it, just go to project's directory and invoke:

```
bundle install
rake db:migrate
rails server
```

Open [application page](http://localhost:3000/) and fill in some user information. Sample texter will be invoked and you'll see an output similar to following in your server log:

```
[ActiveJob] Enqueued Textris::Delay::ActiveJob::Job (Job ID: 71ed54f7-02e8-4205-9093-6f2a0ff7f483) to Inline(textris) with arguments: "UserTexter", "welcome", [#<User id: 1, name: "Mr Jones", phone: "48666777888", created_at: "2015-02-20 17:17:16", updated_at: "2015-02-20 17:17:16">]
[ActiveJob]   User Load (0.3ms)  SELECT  "users".* FROM "users" WHERE "users"."id" = ? LIMIT 1  [["id", 1]]
[ActiveJob] [Textris::Delay::ActiveJob::Job] [71ed54f7-02e8-4205-9093-6f2a0ff7f483] Performing Textris::Delay::ActiveJob::Job from Inline(textris) with arguments: "UserTexter", "welcome", [#<User id: 1, name: "Mr Jones", phone: "48666777888", created_at: "2015-02-20 17:17:16", updated_at: "2015-02-20 17:17:16">]
[ActiveJob] [Textris::Delay::ActiveJob::Job] [71ed54f7-02e8-4205-9093-6f2a0ff7f483] Sent text to +48 666 777 888
[ActiveJob] [Textris::Delay::ActiveJob::Job] [71ed54f7-02e8-4205-9093-6f2a0ff7f483] Texter: User#welcome
[ActiveJob] [Textris::Delay::ActiveJob::Job] [71ed54f7-02e8-4205-9093-6f2a0ff7f483] Date: 2015-02-20 18:17:16 +0100
[ActiveJob] [Textris::Delay::ActiveJob::Job] [71ed54f7-02e8-4205-9093-6f2a0ff7f483] From: Our Team <+48 666 777 888>
[ActiveJob] [Textris::Delay::ActiveJob::Job] [71ed54f7-02e8-4205-9093-6f2a0ff7f483] To: +48 666 777 888
[ActiveJob] [Textris::Delay::ActiveJob::Job] [71ed54f7-02e8-4205-9093-6f2a0ff7f483]   Rendered user_texter/welcome.text.erb (0.4ms)
[ActiveJob] [Textris::Delay::ActiveJob::Job] [71ed54f7-02e8-4205-9093-6f2a0ff7f483] Content: Welcome to our system, Mr Jones!
[ActiveJob] [Textris::Delay::ActiveJob::Job] [71ed54f7-02e8-4205-9093-6f2a0ff7f483] Performed Textris::Delay::ActiveJob::Job from Inline(textris) in 9.98ms
```

Example project may serve as a convenient sandbox for [developing custom delivery methods](#custom-delivery-methods).

## Contributing

1. Fork it (https://github.com/visualitypl/textris/fork)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

### Adding delivery methods

Implementing new delivery methods in Pull Requests is strongly encouraged. Start by [implementing custom delivery method](#custom-delivery-methods). Then, you can prepare it for a Pull Request by adhering to following guidelines:

1. Delivery class should be placed in `lib/textris/delivery/service_name.rb` and named in a way that will best indicate the service with which it's supposed to work with.
5. Add your method to code example in [Choosing and chaining delivery methods](#choosing-and-chaining-delivery-methods) in README. Also, add sub-chapter for it if it depends on other gems or requires explanation.
6. Your delivery code is expected to throw exceptions with self-explanatory messages upon failure. Include specs that test this. Mock external API requests with [webmock](https://github.com/bblimke/webmock).
2. If delivery depends on any gems, don't add them as runtime dependencies. You can (and should in order to write complete specs) add them as development dependencies.
3. Delivery code must load without exceptions even when dependent libraries are missing. Specs should test such case (you can use `remove_const` to undefine loaded consts).
4. New deliveries are expected to have 100% test coverage. Run `COVERAGE=1 bundle exec rake spec` to generate *simplecov* coverage into the **coverage/index.html** file.

The commit in which [the log delivery was added](https://github.com/visualitypl/textris/commit/7c3231ca5eeb94cca01a3beced19a1a909299faf) is an example of delivery method addition that meets all guidelines listed above.
