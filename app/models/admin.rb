class Admin
  include Mongoid::Document
  include MongoSearch::Searchable

  field :name
  field :super_user,         type: Boolean, default: false

  ## Database authenticatable
  field :email,              type: String
  field :encrypted_password, type: String

  ## Recoverable
  field :reset_password_token,   type: String
  field :reset_password_sent_at, type: Time

  ## Rememberable
  field :remember_created_at, type: Time

  ## Trackable
  field :sign_in_count,      type: Integer
  field :current_sign_in_at, type: Time
  field :last_sign_in_at,    type: Time
  field :current_sign_in_ip, type: String
  field :last_sign_in_ip,    type: String

  text_search_in :name, :email

  validates_uniqueness_of :email, case_sensitive: false, scope: :site_id
  validates_presence_of :email
  validates_presence_of :encrypted_password

  devise :database_authenticatable, :recoverable, :rememberable,
    :trackable, :validatable

  def super?
    self.super_user == true
  end

  def as_json(options={})
    super(options).tap do |json|
      json[:last_sign_in_at] = last_sign_in_at

      if current_admin = options[:current_admin]
        json[:current_admin] = current_admin.id == id
      end
    end
  end
end

