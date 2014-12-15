describe Textris::Delivery::Twilio do
  let(:message) do
    Textris::Message.new(
      :to      => ['+48 600 700 800', '+48 100 200 300'],
      :content => 'Some text')
  end

  before do
    class MessageArray
      def create(message)
      end
    end

    module Twilio
      module REST
        class Client
          attr_reader :messages

          def initialize
            @messages = MessageArray.new
          end
        end
      end
    end
  end

  it 'responds to :send_message_to_all' do
    expect(Textris::Delivery::Twilio).to respond_to(:send_message_to_all)
  end

  it 'invokes Twilio REST client for each recipient' do
    expect_any_instance_of(MessageArray).to receive(:create).twice do |context, msg|
      expect(msg).to have_key(:to)
      expect(msg).to have_key(:body)
    end

    Textris::Delivery::Twilio.send_message_to_all(message)
  end
end
