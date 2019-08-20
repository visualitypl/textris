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

      it 'parses short codes properly' do
        message = Textris::Message.new(
          :content => 'X',
          :from    => '894546',
          :to      => '+48 111 222 444')

        expect(message.from_name).to be_nil
        expect(message.from_phone).to eq('894546')
      end

      it 'parses short codes and names properly' do
        message = Textris::Message.new(
          :content => 'X',
          :from    => 'Mr Jones <894546> ',
          :to      => '+48 111 222 444')

        expect(message.from_name).to eq('Mr Jones')
        expect(message.from_phone).to eq('894546')
      end

      it 'parses alphameric IDs and names properly' do
        message = Textris::Message.new(
          :content => 'X',
          :from    => 'Mr Jones <Company> ',
          :to      => '+48 111 222 444')

        expect(message.from_name).to eq('Mr Jones')
        expect(message.from_phone).to eq('Company')
      end
    end

    describe 'parsing :twilio_messaging_service_sid' do
      it 'stores the sid' do
        message = Textris::Message.new(
          content:                      'X',
          twilio_messaging_service_sid: 'MG9752274e9e519418a7406176694466fa',
          to:                           '+48 111 222 444')

        expect(message.twilio_messaging_service_sid)
          .to eq('MG9752274e9e519418a7406176694466fa')
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
      it 'preserves newlines and duplicated whitespace' do
        message = Textris::Message.new(
          :content => "a\nb. \n\n c",
          :from    => 'X',
          :to      => '+48 111 222 333')

        expect(message.content).to eq("a\nb. \n\n c")
      end

      it 'preserves leading whitespace, but strips trailing whitespace' do
        message = Textris::Message.new(
          :content => "  a b. c   ",
          :from    => 'X',
          :to      => '+48 111 222 333')

        expect(message.content).to eq("  a b. c")
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

  describe '#texter' do
    it 'returns raw texter class for :raw => true' do
      message = Textris::Message.new(
        :texter  => String,
        :content => 'X',
        :from    => 'X',
        :to      => '+48 111 222 333')

      expect(message.texter(:raw => true)).to eq String
    end

    it 'returns texter class without modules and texter suffix' do
      module SampleModule
        class SomeSampleTexter; end
      end

      message = Textris::Message.new(
        :texter  => SampleModule::SomeSampleTexter,
        :content => 'X',
        :from    => 'X',
        :to      => '+48 111 222 333')

      expect(message.texter).to eq 'SomeSample'
    end
  end

  describe '#content' do
    before do
      class RenderingTexter < Textris::Base
        def action_with_template
          text :to => '48 600 700 800'
        end
      end
    end

    it 'lazily renders content' do
      renderer = RenderingTexter.new(:action_with_template, [])

      message = Textris::Message.new(
        :renderer => renderer,
        :from     => 'X',
        :to       => '+48 111 222 333')

      expect { message.content }.to raise_error(ActionView::MissingTemplate)
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
      expect(Textris::Delivery).to receive(:get) { [XDelivery, YDelivery] }

      message = Textris::Message.new(
        :content => 'X',
        :from    => 'X',
        :to      => '+48 111 222 333')

      expect_any_instance_of(XDelivery).to receive(:deliver_to_all)
      expect_any_instance_of(YDelivery).to receive(:deliver_to_all)

      message.deliver
    end
  end
end
