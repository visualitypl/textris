class User < ActiveRecord::Base
  validates :name, :phone, :presence => true, :uniqueness => true
  validate :phone_plausible

  def phone_plausible
    errors.add(:phone, :invalid) unless Phony.plausible?(phone)
  end

  def phone=(value)
    Phony.plausible?(value) ? super(Phony.normalize(value)) : value
  end

  after_create do
    UserTexter.welcome(self).deliver
  end
end
