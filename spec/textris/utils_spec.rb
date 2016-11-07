class UtilsHarness
  include Textris::Utils
end

describe Textris::Utils do
  let (:util) { UtilsHarness.new }
  it 'should recognise a 5 digit short code' do
    expect(util.is_short_code?("44397")).to be true
  end

  it 'should recognise a 6 digit short code' do
    expect(util.is_short_code?("894546")).to be true
  end

  it 'should not recognise 7 digits or more as a short code' do
    ['8945467', '89454678', '894546789'].each do |number|
      expect(util.is_short_code?(number)).to be false
    end
  end

  it 'should not recognise 4 digits or less as a short code' do
    ['8945', '894', '89', '8'].each do |number|
      expect(util.is_short_code?(number)).to be false
    end
  end
end
