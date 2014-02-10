class User
  include Mongoid::Document
  # Include default devise modules. Others available are:
  # :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :confirmable, :lockable

  field :is_admin_user,      type: Boolean, default: false

  ## Database authenticatable
  field :email,              type: String, default: ""
  field :encrypted_password, type: String, default: ""

  ## Recoverable
  field :reset_password_token,   type: String
  field :reset_password_sent_at, type: Time

  ## Rememberable
  field :remember_created_at, type: Time

  ## Trackable
  field :sign_in_count,      type: Integer, default: 0
  field :current_sign_in_at, type: Time
  field :last_sign_in_at,    type: Time
  field :current_sign_in_ip, type: String
  field :last_sign_in_ip,    type: String

  ## Confirmable
  field :confirmation_token,   type: String
  field :confirmed_at,         type: Time
  field :confirmation_sent_at, type: Time
  field :unconfirmed_email,    type: String # Only if using reconfirmable

  ## Lockable
  field :failed_attempts, type: Integer, default: 0 # Only if lock strategy is :failed_attempts
  field :unlock_token,    type: String # Only if unlock strategy is :email or :both
  field :locked_at,       type: Time


  ## Suspension
  field :suspended_at,    type: Time

  ## Token authentication
  field :authentication_token, type: String

  index({ authentication_token: 1 }, { unique: true })
  index({ confirmation_token: 1 }, { unique: true })
  index({ unlock_token: 1 }, { unique: true })
  index({ email: 1 }, { unique: true })

  before_save :ensure_authentication_token

  class << self
    def for_authentication_token token
      if where(authentication_token: token).exists?
        user = find_by(authentication_token: token)
        Devise.secure_compare(user.authentication_token, token) ? user : nil
      else
        nil
      end
    end

    def for_confirmation_token token
      confirmation_token = Devise.token_generator.digest(self, :confirmation_token, token)

      if where(confirmation_token: confirmation_token).exists?
        find_by(confirmation_token: confirmation_token)
      else
        nil
      end
    end

    def for_email email
      if User.where(email: email).exists?
        User.find_by(email: email)
      else
        nil
      end
    end
  end

  def ensure_authentication_token
    if authentication_token.blank?
      self.authentication_token = generate_authentication_token
    end
  end

  alias :old_as_json :as_json

  def suspended?
    !suspended_at.blank?
  end

  def suspended= suspended
    set_true = suspended.to_s.downcase[/^true$/].present?

    if set_true
      self.suspended_at = Time.now if suspended_at.blank?
    else
      self.suspended_at = nil
    end
  end

  def as_json options
    fields = old_as_json.except('_id').except('is_admin_user').except('suspended_at')

    if options[:admin]
      fields.merge!(suspended: suspended?)
    else
      if @raw_confirmation_token # @raw_confirmation_token is generated by Devise::Models::Confirmable module
        has_provided_password = !encrypted_password.blank?
        if has_provided_password
          fields.merge!(confirmation_token: @raw_confirmation_token)
        elsif Rails.env.test?
          fields.merge!(confirmation_token_for_tests_only: @raw_confirmation_token)
        end
      else
        fields.merge!(authentication_token: authentication_token)
      end
    end

    fields
  end

  def password_required?
    if is_new_record?
      false # password is not required
    else
      !password.nil? || !password_confirmation.nil? # password is required if it is being set
    end
  end

  private

  def is_new_record?
    !persisted?
  end

  def generate_authentication_token
    loop do
      token = Devise.friendly_token
      break token unless User.where(authentication_token: token).exists?
    end
  end
end

