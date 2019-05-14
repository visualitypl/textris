describe Textris::Delivery::Twilio do

  before do
    class MessageArray
      @created = []

      class << self
        attr_reader :created
      end

      def create(message)
        self.class.created.push(message)
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
    let(:message) do
      Textris::Message.new(
        :to         => ['+48 600 700 800', '+48 100 200 300'],
        :content    => 'Some text',
        :media_urls => [
          'http://example.com/boo.gif',
          'http://example.com/yay.gif'])
    end

    let(:delivery) { Textris::Delivery::Twilio.new(message) }

    it 'invokes Twilio REST client for each recipient' do
      expect_any_instance_of(MessageArray).to receive(:create).twice do |context, msg|
        expect(msg).to have_key(:media_url)
        expect(msg[:media_url]).to eq(message.media_urls)
      end

      delivery.deliver_to_all
    end
  end

  describe 'sending a message using messaging service sid' do
    let(:message) do
      Textris::Message.new(
        to: '+48 600 700 800',
        content: 'Some text',
        twilio_messaging_service_sid: 'MG9752274e9e519418a7406176694466fa')
    end

    let(:delivery) { Textris::Delivery::Twilio.new(message) }

    it 'uses the sid instead of from for the message' do
      delivery.deliver('+11234567890')

      expect(MessageArray.created.last[:from]).to be_nil
      expect(MessageArray.created.last[:messaging_service_sid])
        .to eq('MG9752274e9e519418a7406176694466fa')
    end
  end

  describe "sending from short codes" do
    it 'prepends regular phone numbers code with a +' do
      number = '48 600 700 800'
      message = Textris::Message.new(
        :from       => number,
        :content    => 'Some text',
        :to         => '+48 100 200 300'
      )
      delivery = Textris::Delivery::Twilio.new(message)

      expect_any_instance_of(MessageArray).to receive(:create).once do |context, msg|
        expect(msg).to have_key(:from)
        expect(msg[:from]).to eq("+#{number.gsub(/\s/, '')}")
      end

      delivery.deliver_to_all
    end

    it 'doesn\'t prepend a 6 digit short code with a +' do
      number = '894546'
      message = Textris::Message.new(
        :from       => number,
        :content    => 'Some text',
        :to         => '+48 100 200 300'
      )
      delivery = Textris::Delivery::Twilio.new(message)

      expect_any_instance_of(MessageArray).to receive(:create).once do |context, msg|
        expect(msg).to have_key(:from)
        expect(msg[:from]).to eq(number)
      end

      delivery.deliver_to_all
    end

    it 'doesn\'t prepend a 5 digit short code with a +' do
      number = '44397'
      message = Textris::Message.new(
        :from       => number,
        :content    => 'Some text',
        :to         => '+48 100 200 300'
      )
      delivery = Textris::Delivery::Twilio.new(message)

      expect_any_instance_of(MessageArray).to receive(:create).once do |context, msg|
        expect(msg).to have_key(:from)
        expect(msg[:from]).to eq(number)
      end

      delivery.deliver_to_all
    end
  end
end
