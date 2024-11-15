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
#  started_at         :date
#  tags               :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  host_id            :integer
#
class Event < ApplicationRecord
  devise :database_authenticatable, :registerable,
          :recoverable, :rememberable, :validatable
  belongs_to :host, class_name: "User", foreign_key: "host_id"
  belongs_to :vendorevents, class_name: "VendorEvent", foreign_key: "event_id", dependent: :destroy
end
