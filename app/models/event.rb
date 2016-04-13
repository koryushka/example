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

  attr_accessor :all_day

  validates :title, length: {maximum: 128}, presence: true
  validates :starts_at, date: true, allow_blank: true
  validates :ends_at, date: true, allow_blank: true
  validates :all_day, allow_blank: true, inclusion: {in: [true, false], message: I18n.t('events.should_be_true_or_false')}
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

  before_save do
    set_attributes(starts_on: starts_at, ends_on: nil) if all_day
  end

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
    errors.add(:ends_at, I18n.t('events.start_date_not_end_date')) if starts_at == ends_at
    errors.add(:ends_at, I18n.t('events.start_date_more_than_end_date')) unless ends_at.nil? || starts_at < ends_at
    errors.add(:starts_at, I18n.t('activerecord.errors.messages.blank')) unless all_day && starts_at.present?
  end
end