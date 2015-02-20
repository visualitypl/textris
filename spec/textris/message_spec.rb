describe Textris::Message do
  let(:message) do
    Textris::Message.new(
      :content => 'X',
      :from    => 'X',
      :to      => '+48 111 222 333')
  end

  describe '#initialize' do
    describe 'parsing :from' do
      it 'parses "name <phone>" syntax properly' do
        message = Textris::Message.new(
          :content => 'X',
          :from    => 'Mr Jones <+48 111 222 333> ',
          :to      => '+48 111 222 333')

        expect(message.from_name).to eq('Mr Jones')
        expect(message.from_phone).to eq('48111222333')
      end

      it 'parses phone only properly' do
        message = Textris::Message.new(
          :content => 'X',
          :from    => '+48 111 222 333',
          :to      => '+48 111 222 444')

        expect(message.from_name).to be_nil
        expect(message.from_phone).to eq('48111222333')
      end

      it 'parses name only properly' do
        message = Textris::Message.new(
          :content => 'X',
          :from    => 'Mr Jones',
          :to      => '+48 111 222 444')

        expect(message.from_name).to eq('Mr Jones')
        expect(message.from_phone).to be_nil
      end
    end

    describe 'parsing :to' do
      it 'normalizes phone numbers' do
        message = Textris::Message.new(
          :content => 'X',
          :from    => 'X',
          :to      => '+48 111 222 333')

        expect(message.to).to eq(['48111222333'])
      end

      it 'returns array for singular strings' do
        message = Textris::Message.new(
          :content => 'X',
          :from    => 'X',
          :to      => '+48 111 222 333')

        expect(message.to).to be_a(Array)
      end

      it 'takes arrays of strings' do
        message = Textris::Message.new(
          :content => 'X',
          :from    => 'X',
          :to      => ['+48 111 222 333', '+48 444 555 666'])

        expect(message.to).to eq(['48111222333', '48444555666'])
      end

      it 'filters out unplausible phone numbers' do
        message = Textris::Message.new(
          :content => 'X',
          :from    => 'X',
          :to      => ['+48 111 222 333', 'wrong'])

        expect(message.to).to eq(['48111222333'])
      end
    end

    describe 'parsing :content' do
      it 'cuts newlines and duplicate whitespace' do
        message = Textris::Message.new(
          :content => "a\nb. \n\n c",
          :from    => 'X',
          :to      => '+48 111 222 333')

        expect(message.content).to eq('a b. c')
      end

      it 'strips leading and trailing whitespace' do
        message = Textris::Message.new(
          :content => "  a b. c   ",
          :from    => 'X',
          :to      => '+48 111 222 333')

        expect(message.content).to eq('a b. c')
      end
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
      class XDelivery < Textris::Delivery::Base
        def deliver(to); end
      end

      class YDelivery < Textris::Delivery::Base
        def deliver(to); end
      end
    end

    it 'invokes delivery classes properly' do
      expect(Textris::Delivery).to receive(:get).
        and_return([XDelivery, YDelivery])

      message = Textris::Message.new(
        :content => 'X',
        :from    => 'X',
        :to      => '+48 111 222 333')

      expect_any_instance_of(XDelivery).to receive(:deliver_to_all)
      expect_any_instance_of(YDelivery).to receive(:deliver_to_all)

      message.deliver
    end
  end

  context 'ActiveJob not present' do
    let(:message) do
      Textris::Message.new(
        :content => 'X',
        :from    => 'X',
        :to      => '+48 111 222 333')
    end

    before do
      delegate = Class.new.include(Textris::Delay::ActiveJob::Missing)
      delegate = delegate.new

      [:deliver_now, :deliver_later].each do |method|
        allow(message).to receive(method) { delegate.send(method) }
      end
    end

    describe '#deliver_now' do
      it 'raises' do
        expect do
          message.deliver_now
        end.to raise_error(LoadError)
      end
    end

    describe '#deliver_later' do
      it 'raises' do
        expect do
          message.deliver_later
        end.to raise_error(LoadError)
      end
    end
  end

  context 'ActiveJob present' do
    describe '#deliver_now' do
      before do
        class XDelivery < Textris::Delivery::Base
          def deliver(to); end
        end

        class YDelivery < Textris::Delivery::Base
          def deliver(to); end
        end
      end

      it 'works the same as #deliver' do
        expect(Textris::Delivery).to receive(:get).
          and_return([XDelivery, YDelivery])

        message = Textris::Message.new(
          :content => 'X',
          :from    => 'X',
          :to      => '+48 111 222 333')

        expect_any_instance_of(XDelivery).to receive(:deliver_to_all)
        expect_any_instance_of(YDelivery).to receive(:deliver_to_all)

        message.deliver_now
      end
    end
  end
end
