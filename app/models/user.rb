# == Schema Information
#
# Table name: users
#
#  id                     :bigint           not null, primary key
#  about                  :text
#  confirmation_sent_at   :datetime
#  confirmation_token     :string
#  confirmed_at           :datetime
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  failed_attempts        :integer          default(5), not null
#  first_name             :string
#  last_name              :string
#  locked_at              :datetime
#  photo                  :string
#  private                :boolean          default(FALSE)
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  social_media           :string
#  unconfirmed_email      :string
#  unlock_token           :string
#  username               :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
# Indexes
#
#  index_users_on_confirmation_token    (confirmation_token) UNIQUE
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#  index_users_on_unlock_token          (unlock_token) UNIQUE
#
class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :validatable
  validates :username, presence: true
  validates :email, presence: true, uniqueness: true

  has_many :vendor_events
  has_many :hosted_events, class_name: 'Event', foreign_key: 'host_id'
  has_many :events, through: :vendor_events
  has_many :sent_follow_requests, foreign_key: :sender_id, class_name: 'FollowRequest'
  has_many :received_follow_requests, foreign_key: :recipient_id, class_name: 'FollowRequest'
  has_many :accepted_sent_follow_requests, -> { accepted }, foreign_key: :sender_id, class_name: "FollowRequest"
  has_many :accepted_received_follow_requests, -> { accepted }, foreign_key: :recipient_id, class_name: "FollowRequest"

  has_many :leaders, through: :accepted_sent_follow_requests, source: :recipient, dependent: :destroy
  has_many :followers, through: :accepted_received_follow_requests, source: :sender

  has_many :feed, through: :leaders, source: :events
  has_many :discover, through: :leaders, source: :followers # events of the leaders followers 
  has_many :discovered, through: :discover, source: :events # events of the leaders followers followers

  has_one_attached :photo 

  mount_uploader :photo, PhotoUploader

  
end
