require 'spec_helper'

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

  describe '#text' # TODO

  describe '#deliveries' # TODO

  describe '#call_action' # TODO
end