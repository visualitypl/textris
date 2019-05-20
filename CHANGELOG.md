# 0.7.0 (latest release)

* added support for using Twilio Copilot via messaging_service_sid

# 0.6.0

* new release to support changes made with Nexmo features,
* `respond_to_missing?` defined for base texter,
* corrected an error typo in Message Recipients validation

# 0.5.0 

- **Breaking change**. `Textris::Message#parse_content` no longer strips any
  whitespace characters except for trailing characters. This allows to send
  messages with newlines etc.
- Added support for sending MMS messages via Twilio with `media_urls` option.
- Moved to TravisCI
- Added support for using Twilio Copilot which depends on having a `messaging_service_sid`.
- Fix defaults inheritance (see issue #11)
- Add support for Alphanumeric sender ID
- Add support for Short Codes

