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
  validates :name, presence: true
  validates :application_due_at, presence: true
  validates :started_at, presence: true
  validates :information, presence: true
  validates :application_link, presence: true
  validates :tags, presence: true
  validates :address, presence: true
  
  has_many :users, through: :vendor_events
  has_many :vendor_events, dependent: :destroy

  has_one :host, class_name: 'User', foreign_key: 'host_id'
  has_one_attached :photo
  mount_uploader :photo, PhotoUploader

  scope :past_week, -> {where(:created_at: 1.week.ago...) }
  scope :past_month, -> {where(:created_at: 1.month.ago...) }
  scope :past_three_months, -> {where(:created_at: 3.months.ago...) }
  scope :past_six_months, -> {where(:created_at: 6.months.ago...) }
  scope :past_year, -> {where(:created_at: 1.year.ago...) }

  scope :future, -> {where(:started_at: Date.today..) }
  scope :happening_soon, -> {where(:started_at: Date.today..1.week.from_now) }
  scope :this_month, -> {where(:started_at: Date.today.beginning_of_month..Date.today.end_of_month) }
  scope :next_three_months,{where(:started_at: Date.today..3.months.from_now) }

  scope :by_host, -> (host_id) { where(host_id: host_id) }
  scope :by_tags, -> (tags) { where(tags: tags) }
  scope :by_date, -> (date) { where(started_at: date) }

  
  def self.ransackable_attributes(auth_object = nil)
    %w[name address tags started_at]
  end

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


end
