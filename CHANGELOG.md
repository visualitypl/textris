# 0.5.0 (latest release)

- **Breaking change**. `Textris::Message#parse_content` no longer strips any
  whitespace characters except for trailing characters. This allows to send
  messages with newlines etc.
- Added support for sending MMS messages via Twilio with `media_urls` option.
- Moved to TravisCI
- Fix defaults inheritance (see issue #11)
- Add support for Alphanumeric sender ID
- Add support for Short Codes

