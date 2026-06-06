# == Schema Information
#
# Table name: vendor_events
#
#  id                 :integer          not null, primary key
#  added              :boolean
#  address            :string
#  application_status :string
#  city               :string
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
#  event_id           :integer          not null
#  user_id            :integer          not null
#
# Indexes
#
#  index_vendor_events_on_event_id              (event_id)
#  index_vendor_events_on_user_id               (user_id)
#  index_vendor_events_on_user_id_and_event_id  (user_id,event_id) UNIQUE
#
# Foreign Keys
#
#  event_id  (event_id => events.id) ON DELETE => cascade
#  user_id   (user_id => users.id) ON DELETE => cascade
#
class VendorEvent < ApplicationRecord
  include AlgoliaSearch
  belongs_to :user, required: true, class_name: "User", foreign_key: 'user_id'
  belongs_to :event, required: true, class_name: "Event", foreign_key: 'event_id'
  validates :event_id, uniqueness: { scope: :user_id }
  validate :user_cannot_be_event_host
  
  delegate :name, :address, :started_at, :ends_at, :information, :photo, to: :event, prefix: true


  has_many :notes, dependent: :destroy
  mount_uploader :photo, PhotoUploader
  
  geocoded_by :address
  after_validation :geocode_extraction, if: :address_changed?

  before_save :set_starts_at_from_event

  def self.ransackable_associations(auth_object = nil)
    []
  end

  def self.ransackable_attributes(auth_object = nil)
    %w[name start_time city state]
  end

  def self.search(search)
    if search
      joins(:event).where('name LIKE ? OR address LIKE ? OR tags LIKE ?', "%#{search}%", "%#{search}%", "%#{search}%")
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


  def duration
    return nil unless started_at && ends_at
    ends_at - started_at
  end

  algoliasearch index_name: "VendorEvent" do
    attributes :id, :address, :start_time, :paid, :application_status, :expense, :profit, :return, :sales, :state
  end

  private

  def set_starts_at_from_event
    self.start_time ||= event&.started_at
  end

  def geocode_extraction
    result = Geocoder.search(address).first
    if result
      self.city = result.try(:city) || result.try(:sub_state) || result.try(:county)
      self.state = result.try(:state_code) || result.try(:state)
    end
    Rails.logger.debug "Geocoding VendorEvent: #{address} to City: #{city}, State: #{state}"
  end

  def user_cannot_be_event_host
    return if user.blank? || event.blank?
    return unless event.host_id == user_id

    errors.add(:base, "Hosted events are managed in Hosted Events and cannot be added to My Events.")
  end


end
