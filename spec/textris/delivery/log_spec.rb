describe Textris::Delivery::Log do
  let(:message) do
    Textris::Message.new(
      :from    => 'Mr Jones <+48 555 666 777>',
      :to      => ['+48 600 700 800', '48100200300'],
      :content => 'Some text')
  end

  let(:delivery) { Textris::Delivery::Log.new(message) }
  let(:logger)   { FakeLogger.new }

  before do
    class FakeLogger
      def log(kind = :all)
        @log[kind.to_s] || ""
      end

      def method_missing(name, *args)
        if Textris::Delivery::Log::AVAILABLE_LOG_LEVELS.include?(name.to_s)
          @log ||= {}
          @log[name.to_s] ||= ""
          @log[name.to_s] += args[0] + "\n"
          @log["all"] ||= ""
          @log["all"] += args[0] + "\n"
        end
      end
    end

    Object.send(:remove_const, :Rails) if defined?(Rails)

    Rails = OpenStruct.new(
      :logger => logger,
      :application => OpenStruct.new(
        :config => OpenStruct.new
      )
    )
  end

  after do
    Object.send(:remove_const, :Rails) if defined?(Rails)
  end

  it 'responds to :deliver_to_all' do
    expect(delivery).to respond_to(:deliver_to_all)
  end

  it 'prints proper delivery information to log' do
    delivery.deliver_to_all

    expect(logger.log(:info)).to include "Sent text to +48 600 700 800"
    expect(logger.log(:info)).to include "Sent text to +48 10 020 03 00"

    expect(logger.log(:debug)).to include "Date: "
    expect(logger.log(:debug)).to include "To: +48 600 700 800, +48 600 700 800"
    expect(logger.log(:debug)).to include "Texter: UnknownTexter#unknown_action"
    expect(logger.log(:debug)).to include "From: Mr Jones <+48 55 566 67 77>"
    expect(logger.log(:debug)).to include "Content: Some text"
  end

  it 'applies configured log level' do
    Rails.application.config.textris_log_level = :unknown

    delivery.deliver_to_all

    expect(logger.log(:info)).to be_blank
    expect(logger.log(:debug)).to be_blank
    expect(logger.log(:unknown)).not_to be_blank
  end

  it 'throws error if configured log level is wrong' do
    Rails.application.config.textris_log_level = :wronglevel

    expect do
      delivery.deliver_to_all
    end.to raise_error(ArgumentError)
  end

  context "message with from name and no from phone" do
    let(:message) do
      Textris::Message.new(
        :from    => 'Mr Jones',
        :to      => ['+48 600 700 800', '48100200300'],
        :content => 'Some text')
    end

    it 'prints proper delivery information to log' do
      delivery.deliver_to_all

      expect(logger.log).to include "From: Mr Jones"
    end
  end

  context "message with from phone and no from name" do
    let(:message) do
      Textris::Message.new(
        :from    => '+48 55 566 67 77',
        :to      => ['+48 600 700 800', '48100200300'],
        :content => 'Some text')
    end

    it 'prints proper delivery information to log' do
      delivery.deliver_to_all

      expect(logger.log).to include "From: +48 55 566 67 77"
    end
  end

  context "message with no from" do
    let(:message) do
      Textris::Message.new(
        :to      => ['+48 600 700 800', '48100200300'],
        :content => 'Some text')
    end

    it 'prints proper delivery information to log' do
      delivery.deliver_to_all

      expect(logger.log).to include "From: unknown"
    end
  end

  context "message with twilio messaging service sid" do
    let(:message) do
      Textris::Message.new(
        :twilio_messaging_service_sid => 'MG9752274e9e519418a7406176694466fa',
        :to      => ['+48 600 700 800', '48100200300'],
        :content => 'Some text')
    end

    it 'prints proper delivery information to log' do
      delivery.deliver_to_all

      expect(logger.log).to include "From: MG9752274e9e519418a7406176694466fa"
    end
  end

  context "message with texter and action" do
    let(:message) do
      Textris::Message.new(
        :texter  => "MyClass",
        :action  => "my_action",
        :to      => ['+48 600 700 800', '48100200300'],
        :content => 'Some text')
    end

    it 'prints proper delivery information to log' do
      delivery.deliver_to_all

      expect(logger.log).to include "Texter: MyClass#my_action"
    end
  end

  context "message with media urls" do
    let(:message) do
      Textris::Message.new(
        :from    => 'Mr Jones <+48 555 666 777>',
        :to      => ['+48 600 700 800', '48100200300'],
        :content => 'Some text',
        :media_urls => [
          "http://example.com/hilarious.gif",
          "http://example.org/serious.gif"])
    end

    it 'prints all the media URLs' do
      delivery.deliver_to_all

      expect(logger.log).to include "Media URLs: http://example.com/hilarious.gif"
      expect(logger.log).to include "            http://example.org/serious.gif"
    end
  end
end
