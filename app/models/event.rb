# == Schema Information
#
# Table name: events
#
#  id                 :bigint           not null, primary key
#  address            :string
#  application_due_at :date
#  application_link   :string
#  information        :string
#  latitude           :float
#  longitude          :float
#  name               :string
#  photo              :string
#  started_at         :date
#  tags               :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  host_id            :integer
#
class Event < ApplicationRecord
  has_many :users, through: :vendor_events
  has_many :vendor_events, dependent: :destroy

  has_one :host, class_name: 'User', foreign_key: 'host_id'


  def self.ransackable_attributes(auth_object = nil)
    %w[name address tags started_at]
  end

  validates :name, presence: true
  validates :application_due_at, presence: true
  validates :started_at, presence: true
  validates :information, presence: true
  validates :application_link, presence: true
  validates :tags, presence: true
  validates :address, presence: true



  def self.ransackable_associations(auth_object = nil)
    []
  end

  def self.search(search)
    if search
      where('name LIKE ? OR address LIKE ? OR tags LIKE ?', "%#{search}%", "%#{search}%", "%#{search}%")
    else
      all
    end
  end

  def self.search_by_date(search)
    if search
      where('started_at = ?', "%#{search}%")
    else
      all
    end
  end

  has_one_attached :photo
  mount_uploader :photo, PhotoUploader

end
