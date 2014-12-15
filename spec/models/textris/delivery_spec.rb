describe Textris::Delivery do
  describe '#get' do
    before do
      Object.send(:remove_const, :Rails) if defined?(Rails)

      class FakeEnv
        attr_accessor :test

        def initialize(options = {})
          @test = options[:test]
        end

        def test?
          @test
        end
      end

      Rails = OpenStruct.new(
        :application => OpenStruct.new(
          :config => OpenStruct.new(
            :textris_delivery_method => ['mail', 'test']
          )
        ),
        :env => FakeEnv.new(
          :test? => false
        )
      )
    end

    it 'maps delivery methods from Rails config to delivery classes' do
      expect(Textris::Delivery.get).to eq([
        Textris::Delivery::Mail,
        Textris::Delivery::Test])
    end

    it 'returns an array even for single delivery method' do
      Rails.application.config.textris_delivery_method = 'mail'

      expect(Textris::Delivery.get).to eq([
        Textris::Delivery::Mail])
    end

    it 'defaults to "test" method in test enviroment' do
      Rails.application.config.textris_delivery_method = nil
      Rails.env.test = true

      expect(Textris::Delivery.get).to eq([
        Textris::Delivery::Test])
    end

    it 'defaults to "twilio" method in any other environment' do
      Rails.application.config.textris_delivery_method = nil
      Rails.env.test = false

      expect(Textris::Delivery.get).to eq([
        Textris::Delivery::Twilio])
    end
  end
end
