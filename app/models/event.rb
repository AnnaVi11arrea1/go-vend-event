class Event < ApplicationRecord
  include AlgoliaSearch
  
  geocoded_by :address do |obj, results|
    if (res = results.first)
      obj.city = res.try(:city) || res.try(:sub_state) || res.try(:county)
      obj.state = res.try(:state_code) || res.try(:state)
    end
  end

  after_validation :geocode, if: :address_changed?

  validates :name, presence: true
  validates :started_at, presence: true
  validates :application_link, presence: true
  validates :name, presence: true, uniqueness: { case_sensitive: false }
  has_many :users, through: :vendor_events
  has_many :vendor_events, dependent: :destroy

  after_save :update_vendor_events_start_time

  belongs_to :host, class_name: 'User', foreign_key: 'host_id'
  has_one_attached :photo
  mount_uploader :photo, PhotoUploader

  has_many :comments, dependent: :destroy

  scope :past_week, -> {where(created_at: 1.week.ago...) }
  scope :past_month, -> {where(created_at: 1.month.ago...) }
  scope :past_three_months, -> {where(created_at: 3.months.ago...) }
  scope :past_six_months, -> {where(created_at: 6.months.ago...) }
  scope :past_year, -> {where(created_at: 1.year.ago...) }

  scope :future, -> {where(started_at: Date.today..) }
  scope :happening_soon, -> {where(started_at: Date.today..1.week.from_now) }
  scope :this_month, -> {where(started_at: Date.today.beginning_of_month..Date.today.end_of_month) }
  scope :next_three_months, -> {where(started_at: Date.today..3.months.from_now) }

  scope :by_host, -> (host_id) { where(host_id: host_id) }
  scope :by_tags, -> (tags) { where(tags: tags) }
  scope :by_date, -> (date) { where(started_at: date) }

  
  def self.ransackable_attributes(auth_object = nil)
    %w[name address tags started_at city state]
  end

  algoliasearch index_name: "Event" do
    attributes :name, :address, :tags, :started_at, :latitude, :longitude, :city, :state
    
    # Add started_at as a custom attribute (Unix timestamp for filtering)
    add_attribute :started_at_timestamp do
      started_at&.to_time&.to_i
    end
  end

  private

  def update_vendor_events_start_time
    vendor_events.update_all(start_time: self.started_at)
  end

end
