class CalendarsGroup < AbstractModel
  belongs_to :user
  has_and_belongs_to_many :calendars

  validates :title, length: {maximum: 128}, presence: true
end
