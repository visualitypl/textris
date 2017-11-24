describe Textris::PhoneFormatter do
  it 'should recognise a 4 digit short code' do
    expect(described_class.format("4437")).to eq('4437')
  end

  it 'should recognise a 5 digit short code' do
    expect(described_class.format("44397")).to eq('44397')
  end

  it 'should recognise a 6 digit short code' do
    expect(described_class.format("443975")).to eq('443975')
  end

  it 'treat non-short code non-phone number numbers as alphamerics' do
    ['8945', '894', '89', '8', '8945467', '89454678', '894546789'].each do |number|
      expect(described_class.format(number)).to eq(number)
    end
  end

  it 'prepends phone number with +' do
    expect(described_class.format('48123456789')).to eq('+48123456789')
  end

  it 'does not prepend phone number with + if it already is prepended' do
    expect(described_class.format('+48123456789')).to eq('+48123456789')
  end
end
