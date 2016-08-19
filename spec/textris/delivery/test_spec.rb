describe Textris::Delivery::Test do
  let(:message) do
    Textris::Message.new(
      :to         => ['+48 600 700 800', '+48 100 200 300'],
      :content    => 'Some text',
      :media_urls => ["http://example.com/hilarious.gif"])
  end

  let(:delivery) { Textris::Delivery::Test.new(message) }

  it 'responds to :deliver_to_all' do
    expect(delivery).to respond_to(:deliver_to_all)
  end

  it 'adds proper deliveries to deliveries array' do
    delivery.deliver_to_all

    expect(Textris::Delivery::Test.deliveries.count).to eq 2

    last_message = Textris::Delivery::Test.deliveries.last

    expect(last_message).to be_present
    expect(last_message.content).to eq message.content
    expect(last_message.from_name).to eq message.from_name
    expect(last_message.from_phone).to eq message.from_phone
    expect(last_message.texter).to eq message.texter
    expect(last_message.action).to eq message.action
    expect(last_message.to[0]).to eq message.to[1]
    expect(last_message.media_urls[0]).to eq message.media_urls[0]
  end

  it 'allows clearing messages array' do
    delivery.deliver_to_all

    Textris::Delivery::Test.deliveries.clear

    expect(Textris::Delivery::Test.deliveries).to be_empty
  end
end
