class VendorEvent < ApplicationRecord
  include AlgoliaSearch
  belongs_to :user, required: true, class_name: "User", foreign_key: 'user_id'
  belongs_to :event, required: true, class_name: "Event", foreign_key: 'event_id'
  
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


end
