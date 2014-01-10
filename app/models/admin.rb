class Admin
  include Mongoid::Document
  include MongoSearch::Searchable

  field :name
  field :super_user, type: Boolean, :default => false

  text_search_in :name, :email

  validates_uniqueness_of :email, case_sensitive: false, scope: :site_id

  validates_presence_of :email
  attr_accessible :email, :password, :password_confirmation, :name

  devise :database_authenticatable, :recoverable, :rememberable,
    :trackable, :validatable, :omniauthable

  def self.find_for_domain(domain)
    where(email: /@#{domain}$/).first
  end

  def super?
    self.super_user == true
  end

  def as_json(options)
    super(options).tap do |json|
      if current_admin = options[:current_admin]
        json[:current_admin] = current_admin.id == id
      end
    end
  end
end

