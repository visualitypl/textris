describe Textris::PhoneFormatter do
  it 'should recognise a 4 digit short code' do
    expect(described_class.format("4437")).to eq('4437')
    expect(described_class.is_a_short_code?("4437")).to eq(true)
  end

  it 'should recognise a 5 digit short code' do
    expect(described_class.format("44397")).to eq('44397')
    expect(described_class.is_a_short_code?("44397")).to eq(true)
  end

  it 'should recognise a 6 digit short code' do
    expect(described_class.format("443975")).to eq('443975')
    expect(described_class.is_a_short_code?("443975")).to eq(true)
  end

  it 'treat strings containing at least 1 letter as alphamerics' do
    ['a', '1a', '21a', '321a', '4321a', '54321a', '654321a', '7654321a', '87654321a', '987654321a', '0987654321a'].each do |alphameric|
      expect(described_class.format(alphameric)).to eq(alphameric)
      expect(described_class.is_alphameric?(alphameric)).to eq(true)
    end
  end

  it 'prepends phone number with +' do
    expect(described_class.format('48123456789')).to eq('+48123456789')
    expect(described_class.is_a_phone_number?('48123456789')).to eq(true)
  end

  it 'does not prepend phone number with + if it already is prepended' do
    expect(described_class.format('+48123456789')).to eq('+48123456789')
    expect(described_class.is_a_phone_number?('+48123456789')).to eq(true)
  end
end
