describe Textris::Delivery::Twilio do

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

  describe "sending multiple messages" do
    let(:message) do
      Textris::Message.new(
        :to         => ['+48 600 700 800', '+48 100 200 300'],
        :content    => 'Some text')
    end

    let(:delivery) { Textris::Delivery::Twilio.new(message) }

    it 'responds to :deliver_to_all' do
      expect(delivery).to respond_to(:deliver_to_all)
    end

    it 'invokes Twilio REST client for each recipient' do
      expect_any_instance_of(MessageArray).to receive(:create).twice do |context, msg|
        expect(msg).to have_key(:to)
        expect(msg).to have_key(:body)
        expect(msg).not_to have_key(:media_url)
        expect(msg[:body]).to eq(message.content)
      end

      delivery.deliver_to_all
    end
  end

  describe "sending media messages" do

    describe "sending a single media url" do
      let(:message) do
        Textris::Message.new(
          :to         => ['+48 600 700 800', '+48 100 200 300'],
          :content    => 'Some text',
          :media_url  => 'http://example.com/boo.gif')
      end

      let(:delivery) { Textris::Delivery::Twilio.new(message) }

      it 'invokes Twilio REST client for each recipient' do
        expect_any_instance_of(MessageArray).to receive(:create).twice do |context, msg|
          expect(msg).to have_key(:media_url)
          expect(msg[:media_url]).to eq(message.media_url)
        end

        delivery.deliver_to_all
      end
    end

    describe "sending multiple media urls" do
      let(:message) do
        Textris::Message.new(
          :to         => ['+48 600 700 800', '+48 100 200 300'],
          :content    => 'Some text',
          :media_url  => [
            'http://example.com/boo.gif',
            'http://example.com/yay.gif'])
      end

      let(:delivery) { Textris::Delivery::Twilio.new(message) }

      it 'invokes Twilio REST client for each recipient' do
        expect_any_instance_of(MessageArray).to receive(:create).twice do |context, msg|
          expect(msg).to have_key(:media_url)
          expect(msg[:media_url]).to eq(message.media_url)
        end

        delivery.deliver_to_all
      end
    end
  end
end
