describe Textris::Delay::Sidekiq do
  before do
    class MyTexter < Textris::Base
      def delayed_action(phone, body)
        text :to => phone, :body => body
      end

      def serialized_action(user)
        text :to => user.id, :body => 'Hello'
      end

      def serialized_array_action(users)
        text :to => users.first.id, :body => 'Hello all'
      end
    end

    module ActiveRecord
      class RecordNotFound < Exception; end

      class Base
        attr_reader :id

        def initialize(id)
          @id = id
        end

        def self.find(id)
          if id.is_a?(Array)
            id.collect do |id|
              id.to_i > 0 ? new(id) : raise(RecordNotFound)
            end
          else
            id.to_i > 0 ? new(id) : raise(RecordNotFound)
          end
        end
      end

      class Relation
        attr_reader :model, :items

        delegate :map, :to => :items

        def initialize(model, items)
          @model = model
          @items = items
        end
      end
    end

    class XModel    < ActiveRecord::Base; end
    class YModel    < ActiveRecord::Base; end
    class XRelation < ActiveRecord::Relation; end
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

      it 'serializes and deserializes ActiveRecord records' do
        user = XModel.new('48666777888')

        MyTexter.delay.serialized_action(user)

        expect_any_instance_of(MyTexter).to receive(:text).with(
          :to => "48666777888", :body => "Hello").and_call_original
        expect_any_instance_of(Textris::Message).to receive(:deliver)

        expect do
          Textris::Delay::Sidekiq::Worker.drain
        end.not_to raise_error
      end

      it 'serializes and deserializes ActiveRecord relations' do
        users = XRelation.new(XModel, [XModel.new('48666777888'), XModel.new('48666777889')])

        MyTexter.delay.serialized_array_action(users)

        expect_any_instance_of(MyTexter).to receive(:text).with(
          :to => "48666777888", :body => "Hello all").and_call_original
        expect_any_instance_of(Textris::Message).to receive(:deliver)

        expect do
          Textris::Delay::Sidekiq::Worker.drain
        end.not_to raise_error
      end

      it 'serializes and deserializes ActiveRecord object arrays' do
        users = [XModel.new('48666777888'), XModel.new('48666777889')]

        MyTexter.delay.serialized_array_action(users)

        expect_any_instance_of(MyTexter).to receive(:text).with(
          :to => "48666777888", :body => "Hello all").and_call_original
        expect_any_instance_of(Textris::Message).to receive(:deliver)

        expect do
          Textris::Delay::Sidekiq::Worker.drain
        end.not_to raise_error
      end

      it 'does not serialize wrong ActiveRecord object arrays' do
        users = [XModel.new('48666777888'), YModel.new('48666777889')]

        MyTexter.delay.serialized_array_action(users)

        expect do
          Textris::Delay::Sidekiq::Worker.drain
        end.to raise_error(NoMethodError)
      end

      it 'does not raise when ActiveRecord not loaded' do
        Object.send(:remove_const, :XModel)
        Object.send(:remove_const, :YModel)
        Object.send(:remove_const, :XRelation)
        Object.send(:remove_const, :ActiveRecord)

        MyTexter.delay.serialized_array_action('x')

        expect do
          Textris::Delay::Sidekiq::Worker.drain
        end.to raise_error(NoMethodError)
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
        travel_to(Date.new(2019,1,1)) do
          MyTexter.delay_until(Time.new(2020, 1, 1)).delayed_action(
            '48111222333', 'Hi')

          expect_any_instance_of(MyTexter).to receive(:text).with(
            :to => "48111222333", :body => "Hi").and_call_original
          expect_any_instance_of(Textris::Message).to receive(:deliver)

          scheduled_at = Time.at(Textris::Delay::Sidekiq::Worker.jobs.last['at'])

          expect(scheduled_at).to eq Time.new(2020, 1, 1)

          Textris::Delay::Sidekiq::Worker.drain
        end
      end

      it 'raises with wrong timestamp' do
        expect do
          MyTexter.delay_until(nil)
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
