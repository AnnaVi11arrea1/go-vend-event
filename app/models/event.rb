# == Schema Information
#
# Table name: events
#
#  id                 :bigint           not null, primary key
#  address            :string
#  application_due_at :date
#  application_link   :string
#  information        :string
#  name               :string
#  started_at         :date
#  tags               :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  host_id            :integer
#
class Event < ApplicationRecord
end
