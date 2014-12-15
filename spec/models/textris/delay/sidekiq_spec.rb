describe Textris::Delay::Sidekiq do
  before do
    class MyTexter < Textris::Base
      include Textris::Delay::Sidekiq

      def delayed_action(phone, body)
        text :to => phone, :body => body
      end
    end
  end

  describe '#delay' do
    it 'schedules action with proper params' do
      MyTexter.delay.delayed_action('48111222333', 'Hi')

      expect_any_instance_of(MyTexter).to receive(:text).with(
        :to => "48111222333", :body => "Hi").and_call_original
      expect_any_instance_of(Textris::Message).to receive(:deliver)

      Textris::Delay::Sidekiq::Worker.drain
    end
  end

  describe '#delay_for' do
    it 'schedules action with proper params' do
      MyTexter.delay_for(300).delayed_action('48111222333', 'Hi')

      expect_any_instance_of(MyTexter).to receive(:text).with(
        :to => "48111222333", :body => "Hi").and_call_original
      expect_any_instance_of(Textris::Message).to receive(:deliver)

      Textris::Delay::Sidekiq::Worker.drain
    end

    it 'raises with wrong interval' do
      expect do
        MyTexter.delay_for('x')
      end.to raise_error(ArgumentError)
    end
  end

  describe '#delay_until' do
    it 'schedules action with proper params' do
      MyTexter.delay_until(Time.new(2005, 1, 1)).delayed_action(
        '48111222333', 'Hi')

      expect_any_instance_of(MyTexter).to receive(:text).with(
        :to => "48111222333", :body => "Hi").and_call_original
      expect_any_instance_of(Textris::Message).to receive(:deliver)

      Textris::Delay::Sidekiq::Worker.drain
    end

    it 'raises with wrong timestamp' do
      expect do
        MyTexter.delay_until('x')
      end.to raise_error(ArgumentError)
    end
  end
end