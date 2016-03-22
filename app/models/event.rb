class Event < ActiveRecord::Base
  belongs_to :user
  has_and_belongs_to_many :calendars
  has_and_belongs_to_many :documents
  has_one :notifications_preference
  has_many :complex_events, foreign_key: 'id'
  has_many :event_recurrences, dependent: :destroy
  has_one :event_cancellation, dependent: :destroy

  accepts_nested_attributes_for :event_recurrences
  accepts_nested_attributes_for :event_cancellation

  validates :title, length: {maximum: 128}, presence: true
  validates :starts_at, date: true, presence: true
  validates :ends_at, date: true, presence: true
  validates :separation, numericality: { only_integer: true }, allow_blank: true
  validates :count, numericality: { only_integer: true }, allow_blank: true
  validates :until, date: true, allow_blank: true
  validates :notes, length: {maximum: 2048}
  validates :kind, allow_blank: true, numericality: {only_integer: true}
  validates :longitude, numericality: {only_integer: false}, allow_blank: true
  validates :latitude, numericality: {only_integer: false}, allow_blank: true
  validates :frequency, inclusion: {in: %w(once daily weekly monthly yearly)}

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
end