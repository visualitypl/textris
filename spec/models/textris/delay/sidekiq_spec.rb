describe Textris::Delay::Sidekiq do
  before do
    class MyTexter < Textris::Base
      def delayed_action(phone, body)
        text :to => phone, :body => body
      end
    end
  end

  context 'sidekiq gem present' do
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
      it 'schedules action with proper params and execution time' do
        MyTexter.delay_for(300).delayed_action('48111222333', 'Hi')

        expect_any_instance_of(MyTexter).to receive(:text).with(
          :to => "48111222333", :body => "Hi").and_call_original
        expect_any_instance_of(Textris::Message).to receive(:deliver)

        scheduled_at = Time.at(Textris::Delay::Sidekiq::Worker.jobs.last['at'])

        expect(scheduled_at).to be > Time.now + 250

        Textris::Delay::Sidekiq::Worker.drain
      end

      it 'raises with wrong interval' do
        expect do
          MyTexter.delay_for('x')
        end.to raise_error(ArgumentError)
      end
    end

    describe '#delay_until' do
      it 'schedules action with proper params and execution time' do
        MyTexter.delay_until(Time.new(2020, 1, 1)).delayed_action(
          '48111222333', 'Hi')

        expect_any_instance_of(MyTexter).to receive(:text).with(
          :to => "48111222333", :body => "Hi").and_call_original
        expect_any_instance_of(Textris::Message).to receive(:deliver)

        scheduled_at = Time.at(Textris::Delay::Sidekiq::Worker.jobs.last['at'])

        expect(scheduled_at).to eq Time.new(2020, 1, 1)

        Textris::Delay::Sidekiq::Worker.drain
      end

      it 'raises with wrong timestamp' do
        expect do
          MyTexter.delay_until('x')
        end.to raise_error(ArgumentError)
      end
    end
  end

  context 'sidekiq gem not present' do
    before do
      delegate = Class.new.extend(Textris::Delay::Sidekiq::Missing)

      [:delay, :delay_for, :delay_until].each do |method|
        allow(Textris::Base).to receive(method) { delegate.send(method) }
      end
    end

    describe '#delay' do
      it 'raises' do
        expect do
          MyTexter.delay
        end.to raise_error(LoadError)
      end
    end

    describe '#delay_for' do
      it 'raises' do
        expect do
          MyTexter.delay_for(300)
        end.to raise_error(LoadError)
      end
    end

    describe '#delay_until' do
      it 'raises' do
        expect do
          MyTexter.delay_until(Time.new(2005, 1, 1))
        end.to raise_error(LoadError)
      end
    end
  end
end
