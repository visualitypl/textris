class User < ActiveRecord::Base
  validates :name, :phone, :presence => true, :uniqueness => true
  validate :phone_plausible

  def phone_plausible
    errors.add(:phone, :invalid) if phone.present? && !Phony.plausible?(phone)
  end

  def phone=(value)
    Phony.plausible?(value) ? super(Phony.normalize(value)) : super(value)
  end

  after_create do
    ## This would send SMS instantly and slow app down...
    # UserTexter.welcome(self).deliver_now

    ## ...so let's use shiny, async ActiveJob instead
    UserTexter.welcome(self).deliver_later
  end
end
