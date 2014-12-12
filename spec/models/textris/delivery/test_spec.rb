require 'spec_helper'

describe Textris::Delivery::Test do
  let(:message) do
    Textris::Message.new(
      :to      => '+48 600 700 800',
      :content => 'Some text')
  end

  it 'adds delievries to messages array' do
    Textris::Delivery::Test.send_message_to_all(message)

    expect(Textris::Delivery::Test.messages).to be_any
  end
end