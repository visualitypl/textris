describe Textris::Delivery::Mail::Mailer do
  describe '#notify' do
    it 'invokes mail with given from, to subject and body' do
      mailer = Textris::Delivery::Mail::Mailer

      expect_any_instance_of(mailer).to receive(:mail).with(
        :from => "a", :to => "b" , :subject => "c", :body => "d")

      mailer.notify('a', 'b', 'c', 'd')
    end
  end
end
