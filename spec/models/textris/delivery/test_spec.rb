require 'spec_helper'

describe Textris::Delivery::Test do
  let(:message) do
    Textris::Message.new(
      :to      => '+48 600 700 800',
      :content => 'Some text')
  end

  it 'responds to :send_message_to_all' do
    expect(Textris::Delivery::Test).to respond_to(:send_message_to_all)
  end

  it 'adds proper delievries to deliveries array' do
    Textris::Delivery::Test.send_message_to_all(message)

    last_message = Textris::Delivery::Test.deliveries.last

    expect(last_message).to be_present
    expect(last_message.content).to eq message.content
    expect(last_message.from_name).to eq message.from_name
    expect(last_message.from_phone).to eq message.from_phone
    expect(last_message.texter).to eq message.texter
    expect(last_message.action).to eq message.action
    expect(last_message.to).to eq message.to
  end

  it 'allows clearing messages array' do
    Textris::Delivery::Test.send_message_to_all(message)
    Textris::Delivery::Test.deliveries.clear

    expect(Textris::Delivery::Test.deliveries).to be_empty
  end
end