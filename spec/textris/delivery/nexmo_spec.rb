describe Textris::Delivery::Nexmo do
  let(:message) do
    Textris::Message.new(
    :to      => ['+48 600 700 800', '+48 100 200 300'],
    :content => 'Some text',
    :from    => 'Alpha ID')
  end

  let(:delivery) { Textris::Delivery::Nexmo.new(message) }

  before do
    module Nexmo
      class Client
        def send_message(params)
          params
        end
      end
    end
  end

  it 'responds to :deliver_to_all' do
    expect(delivery).to respond_to(:deliver_to_all)
  end

  it 'invokes Nexmo::Client#send_message twice for each recipient' do
    expect_any_instance_of(Nexmo::Client).to receive(:send_message).twice do |context, msg|
      expect(msg).to have_key(:from)
      expect(msg).to have_key(:to)
      expect(msg).to have_key(:text)
    end

    delivery.deliver_to_all
  end

  describe '#deliver' do
    subject { delivery.deliver('48600700800') }

    context 'when from_phone is nil' do
      it 'will use from_name' do
        expect(subject[:from]).to eq 'Alpha ID'
      end
    end
  end
end
