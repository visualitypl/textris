describe Textris::Base do
  describe '#default' do
    it 'sets defaults' do
      some_texter = Class.new(Textris::Base)

      expect do
        some_texter.instance_eval do
          default :from => "Me"
        end
      end.not_to raise_error

      defaults = some_texter.instance_variable_get('@defaults')[:from]

      expect(some_texter.instance_variable_get('@defaults')).to have_key(:from)
    end

    it 'keeps separate defaults for each descendant' do
      some_texter = Class.new(Textris::Base)
      other_texter = Class.new(Textris::Base)
      deep_texter = Class.new(some_texter)

      some_texter.instance_eval do
        default :from => "Me"
      end

      other_texter.instance_eval do
        default :to => "123"
      end

      deep_texter.instance_eval do
        default :from => "Us", :to => "456"
      end

      defaults = some_texter.instance_variable_get('@defaults')
      expect(defaults).to have_key(:from)
      expect(defaults).not_to have_key(:to)

      defaults = other_texter.instance_variable_get('@defaults')
      expect(defaults).not_to have_key(:from)
      expect(defaults).to have_key(:to)

      defaults = deep_texter.instance_variable_get('@defaults')
      expect(defaults[:from]).to eq 'Us'
      expect(defaults[:to]).to eq '456'
    end
  end

  describe '#with_defaults' do
    it 'merges back defaults' do
      some_texter = Class.new(Textris::Base)

      some_texter.instance_eval do
        default :from => "Me"
      end

      options = some_texter.with_defaults(:to => '123')

      expect(options[:from]).to eq 'Me'
      expect(options[:to]).to eq '123'
    end
  end

  describe '#deliveries' do
    it 'maps to Textris::Delivery::Test.deliveries' do
      allow(Textris::Delivery::Test).to receive_messages(:deliveries => ['x'])

      expect(Textris::Base.deliveries).to eq (['x'])
    end
  end

  describe '#text' do
    before do
      class MyTexter < Textris::Base
        def action_with_inline_body
          text :to => '48 600 700 800', :body => 'asd'
        end

        def action_with_template
          text :to => '48 600 700 800'
        end

        def set_instance_variable(key, value)
        end
      end
    end

    it 'renders inline content when :body provided' do
      MyTexter.action_with_inline_body
    end

    it 'defers template rendering when :body not provided' do
      render_options = {}

      expect_any_instance_of(MyTexter).not_to receive(:render)

      MyTexter.action_with_template
    end
  end

  describe '#my_action' do
    before do
      class MyTexter < Textris::Base
        def my_action(p)
          p[:calls] += 1
        end
      end
    end

    it 'calls actions on newly created instances' do
      call_info = { :calls => 0 }

      MyTexter.my_action(call_info)

      expect(call_info[:calls]).to eq(1)
    end
  end

  describe Textris::Base::RenderingController do
    before do
      class Textris::Base::RenderingController
        def initialize(*args)
        end
      end

      class ActionMailer::Base
        def self.default_url_options
          'x'
        end
      end
    end

    it 'maps default_url_options to ActionMailer configuration' do
      rendering_controller = Textris::Base::RenderingController.new

      expect(rendering_controller.default_url_options).to eq 'x'
    end
  end
end
