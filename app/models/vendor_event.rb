# == Schema Information
#
# Table name: vendor_events
#
#  id                 :integer          not null, primary key
#  added              :boolean
#  address            :string
#  application_status :string
#  description        :text
#  expense            :float
#  paid               :boolean
#  photo              :string
#  profit             :float
#  return             :float
#  sales              :float
#  start_time         :datetime
#  state              :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  event_id           :integer
#  user_id            :integer
#
class VendorEvent < ApplicationRecord
  
  belongs_to :user, required: true, class_name: "User", foreign_key: 'user_id'
  belongs_to :event, required: true, class_name: "Event", foreign_key: 'event_id'
  
  delegate :name, :latitude, :longitude, to: :event, prefix: true

  has_one_attached :photo
  has_one :address, :through => :address, :source => :events
  has_many :comments, dependent: :destroy
  mount_uploader :photo, PhotoUploader
  
  geocoded_by :address
  after_validation :geocode, if: ->(obj){ obj.address.present? and obj.address_changed? }

  reverse_geocoded_by :event_latitude, :event_longitude, address: :location do |obj, results|
      if geo = results.first
        obj.state    = geo.state
      end
    end

    def latitude_for_geocoding
      event_latitude
    end
    
    def longitude_for_geocoding
      event_longitude
    end
    
  after_validation :reverse_geocode

  attr_accessor :state

  has_one :started_at,  :through => :started_at, :source => :events
  has_one :ends_at,     :through => :ends_at, :source => :events
  has_one :description, :through => :information, :source => :events

  before_save :set_starts_at_from_event
  def self.ransackable_associations(auth_object = nil)
    []
  end

  def self.ransackable_attributes(auth_object = nil)
    %w[name paid application_status]
  end

  def self.search(search)
    if search
      where('name LIKE ? OR application_status LIKE ? OR paid LIKE ?', "%#{search}%", "%#{search}%", "%#{search}%")
    else
      all
    end
  end

  def combined_location
    "#{event_latitude},#{event_longitude}"
  end

  def duration
    return nil unless started_at && ends_at
    ends_at - started_at
  end


  private

  def set_starts_at_from_event
    self.start_time ||= event&.started_at
  end


end
