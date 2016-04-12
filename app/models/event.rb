class Event < AbstractModel
  belongs_to :user
  has_and_belongs_to_many :calendars
  has_and_belongs_to_many :documents
  has_one :notifications_preference
  has_many :complex_events, foreign_key: 'id'
  has_many :event_recurrences, dependent: :destroy
  has_many :event_cancellations, dependent: :destroy

  accepts_nested_attributes_for :event_recurrences
  accepts_nested_attributes_for :event_cancellations

  validates :title, length: {maximum: 128}, presence: true
  validates :starts_at, date: true, presence: true
  validates :ends_at, date: true, presence: true
  validates :starts_on, date: true, allow_blank: true
  validates :ends_on, date: true, allow_blank: true
  validates :separation, numericality: { only_integer: true, greater_than: 0 }, allow_blank: true
  validates :count, numericality: { only_integer: true }, allow_blank: true
  validates :until, date: true, allow_blank: true
  validates :notes, length: {maximum: 2048}
  validates :kind, allow_blank: true, numericality: {only_integer: true}
  validates :longitude, numericality: {only_integer: false}, allow_blank: true
  validates :latitude, numericality: {only_integer: false}, allow_blank: true
  validates :frequency, inclusion: {in: %w(once daily weekly monthly yearly)}

  validate :dates_check

  default :separation, 1
  default :notes, ''
  default :kind, 0

#  validate :weekly_recurency_check

private
  # def weekly_recurency_check
  #   return if frequency != 'weekly' && event_recurrences.empty?
  #
  #   event_recurrences.each do |er|
  #     if er.week.nil? && er.month.nil?
  #       if er.day.nil?
  #         errors.add(:frequency, 'You must specify a day of week for every recurency if you want to repeat event weekly')
  #         break
  #       end
  #     else
  #       errors.add(:frequency, 'You cannot specify week or month for weekly event, day is allowed only')
  #       break
  #     end
  #   end
  # end

  def dates_check
    errors.add(:ends_at, 'should not be equal to start date') if starts_at == ends_at
    errors.add(:ends_at, 'should not more than start date') unless ends_at.nil? || starts_at < ends_at
  end
end