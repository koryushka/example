class EventCancellation < ActiveRecord::Base
  belongs_to :event

  validates 'date', date: true, presence: true
end