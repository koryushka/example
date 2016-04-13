class EventCancellation < AbstractModel
  belongs_to :event

  validates 'date', date: true, presence: true
end