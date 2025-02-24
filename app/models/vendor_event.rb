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
  
  delegate :name, :address, :started_at, :ends_at, :information, to: :event, prefix: true

  has_one_attached :photo

  has_many :comments, dependent: :destroy
  mount_uploader :photo, PhotoUploader
  
  geocoded_by :address


  before_save :set_starts_at_from_event

  def self.ransackable_associations(auth_object = nil)
    []
  end

  def self.ransackable_attributes(auth_object = nil)
    %w[name start_time]
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


  private

  def set_starts_at_from_event
    self.start_time ||= event&.started_at
  end


end
