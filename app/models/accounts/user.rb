class Accounts::User < ApplicationRecord
  extend FriendlyId

  self.implicit_order_column = "created_at"

  devise :database_authenticatable, :registerable, :trackable, :lockable,
    :recoverable, :confirmable, :timeoutable, :rememberable, :validatable

  validates :password, password_strength: {use_dictionary: true}, allow_nil: true
  after_validation :strip_unnecessary_errors

  has_many :memberships, dependent: :delete_all, inverse_of: :user
  has_many :organizations, -> { where(status: :active) }, through: :memberships
  has_many :all_organizations, through: :memberships, source: :organization

  friendly_id :full_name, use: :slugged

  auto_strip_attributes :full_name, :preferred_name, squish: true

  accepts_nested_attributes_for :organizations

  def organization
    # for now, just assume that user has membership with
    # only one organization
    organizations.first
  end

  def membership
    # for now, just assume that user has membership with
    # only one organization
    memberships.first
  end

  def create_with_membership
    return false unless valid?
    return false if membership.blank?
    return false if organization.blank?

    membership&.role = Accounts::Membership.roles[:executive]
    organization.created_by = email
    organization.status = Accounts::Organization.statuses[:active]
    save

    self
  rescue ActiveRecord::RecordInvalid => e
    logger.error(e)
    self
  end

  private

  # We only want to display one error message to the user, so if we get multiple
  # errors clear out all errors and present our nice message to the user.
  def strip_unnecessary_errors
    if errors[:password].any? && errors[:password].size > 1
      errors.delete(:password)
      errors.add(:password, t("errors.messages.password.password_strength"))
    end
  end
end