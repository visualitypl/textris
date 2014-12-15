describe Textris::Message do
  let(:message) do
    Textris::Message.new(
      :content => 'X',
      :from    => 'X',
      :to      => '+48 111 222 333')
  end

  describe '#initialize' do
    it 'parses :from' do
      expect_any_instance_of(Textris::Message).to receive(:parse_from)

      Textris::Message.new(
        :content => 'X',
        :from    => 'X',
        :to      => '+48 111 222 333')
    end

    it 'parses :to' do
      expect_any_instance_of(Textris::Message).to receive(:parse_to).
        and_return(['48111222333'])

      Textris::Message.new(
        :content => 'X',
        :from    => '+48 111 222 333',
        :to      => '+48 111 222 333')
    end

    it 'parses :content' do
      expect_any_instance_of(Textris::Message).to receive(
        :parse_content).and_return('X')

      Textris::Message.new(
        :content => 'X',
        :from    => 'X',
        :to      => '+48 111 222 333')
    end

    it 'raises if :to not provided' do
      expect do
        Textris::Message.new(
          :content => 'X',
          :from    => 'X',
          :to      => nil)
      end.to raise_error(ArgumentError)
    end

    it 'raises if :content not provided' do
      expect do
        Textris::Message.new(
          :content => nil,
          :from    => 'X',
          :to      => '+48 111 222 333')
      end.to raise_error(ArgumentError)
    end
  end

  describe '#deliver' do
    before do
      class XDelivery
        def self.send_message_to_all(message); end
      end

      class YDelivery
        def self.send_message_to_all(message); end
      end
    end

    it 'invokes delivery classes properly' do
      expect(Textris::Delivery).to receive(:get).
        and_return([XDelivery, YDelivery])

      message = Textris::Message.new(
        :content => 'X',
        :from    => 'X',
        :to      => '+48 111 222 333')

      expect(XDelivery).to receive(:send_message_to_all).with(message)
      expect(YDelivery).to receive(:send_message_to_all).with(message)

      message.deliver
    end
  end

  describe '#parse_from' do
    it 'parses "name <phone>" syntax properly' do
      name, phone = message.instance_eval{ parse_from('Mr Jones <+48 111 222 333> ') }

      expect(name).to eq('Mr Jones')
      expect(phone).to eq('48111222333')
    end

    it 'parses phone only properly' do
      name, phone = message.instance_eval{ parse_from('+48 111 222 333') }

      expect(name).to be_nil
      expect(phone).to eq('48111222333')
    end

    it 'parses name only properly' do
      name, phone = message.instance_eval{ parse_from('Mr Jones') }

      expect(name).to eq('Mr Jones')
      expect(phone).to be_nil
    end
  end

  describe '#parse_to' do
    it 'normalizes phone numbers' do
      to = message.instance_eval{ parse_to('+48 111 222 333') }

      expect(to).to eq(['48111222333'])
    end

    it 'returns array for singular strings' do
      to = message.instance_eval{ parse_to('+48 111 222 333') }

      expect(to).to be_a(Array)
    end

    it 'takes arrays of strings' do
      to = message.instance_eval{ parse_to(['+48 111 222 333', '+48 444 555 666']) }

      expect(to).to eq(['48111222333', '48444555666'])
    end

    it 'filters out unplausible phone numbers' do
      to = message.instance_eval{ parse_to(['+48 111 222 333', 'wrong']) }

      expect(to).to eq(['48111222333'])
    end
  end

  describe '#parse_content' do
    it 'cuts newlines and duplicate whitespace' do
      content = message.instance_eval{ parse_content("a\nb. \n\n c") }

      expect(content).to eq('a b. c')
    end

    it 'strips leading and trailing whitespace' do
      content = message.instance_eval{ parse_content("  a b. c   ") }

      expect(content).to eq('a b. c')
    end
  end
end
