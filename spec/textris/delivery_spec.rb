describe Textris::Delivery do
  describe '#get' do
    before do
      Object.send(:remove_const, :Rails) if defined?(Rails)

      class FakeEnv
        def initialize(options = {})
          self.name = 'development'
        end

        def name=(value)
          @development = false
          @test        = false
          @production  = false

          case value.to_s
          when 'development'
            @development = true
          when 'test'
            @test = true
          when 'production'
            @production = true
          end
        end

        def development?
          @development
        end

        def test?
          @test
        end

        def production?
          @production
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

    after do
      Object.send(:remove_const, :Rails) if defined?(Rails)
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

    it 'defaults to "log" method in development environment' do
      Rails.application.config.textris_delivery_method = nil
      Rails.env.name = 'development'

      expect(Textris::Delivery.get).to eq([
        Textris::Delivery::Log])
    end

    it 'defaults to "test" method in test enviroment' do
      Rails.application.config.textris_delivery_method = nil
      Rails.env.name = 'test'

      expect(Textris::Delivery.get).to eq([
        Textris::Delivery::Test])
    end

    it 'defaults to "mail" method in production enviroment' do
      Rails.application.config.textris_delivery_method = nil
      Rails.env.name = 'production'

      expect(Textris::Delivery.get).to eq([
        Textris::Delivery::Mail])
    end
  end
end
