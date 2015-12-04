class Session
  include ActiveModel::Conversion
  include ActiveModel::Validations

  attr_accessor :email, :password

  validate :email_exists
  validate :password_is_valid, if: -> { admin? }

  def initialize(attrs = {})
    attrs.each do |k, v|
      public_send("#{k}=", v)
    end
  end

  def admin
    @admin ||= Admin.find_by(email: email)
  rescue Mongoid::RecordNotFound
    nil
  end

  def persisted?
    false
  end

  private

  def admin?
    admin.present?
  end

  def email_exists
    errors.add(:email, :invalid) unless admin?
  end

  def password_is_valid
    errors.add(:password, :invalid) unless admin.authenticate(password)
  end
end
