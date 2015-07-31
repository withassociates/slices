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

  validates_uniqueness_of :email, case_sensitive: false
  validates_presence_of :encrypted_password

  devise :database_authenticatable, :recoverable, :rememberable,
    :trackable, :validatable

  def as_json(options = {})
    current_admin_id = options[:current_admin].try(:id)
    {
      _id: id.to_s,
      name: name,
      email: email,
      current_admin: (current_admin_id == id),
      last_sign_in_at: last_sign_in_at,
      super_user: super_user,
    }
  end

end

