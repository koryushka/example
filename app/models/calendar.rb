class Calendar < ActiveRecord::Base
  belongs_to :user
  has_and_belongs_to_many :events
  has_and_belongs_to_many :calendars_groups
  has_and_belongs_to_many :complex_events, join_table: 'calendars_events', readonly: true, association_foreign_key: 'event_id'

  validates :title, length: {maximum: 128}, presence: true
  validates :hex_color, length: {maximum: 6}
  validates :main, allow_blank: true, inclusion: {in: [true, false]}
  validates :kind, allow_blank: true, numericality: {only_integer: true}
  validates :visible, allow_blank: true, inclusion: {in: [true, false]}

  def shared_events
    if self.main?
      cic = Arel::Table.new(:calendars_events)
      sharings = SharingPermission.arel_table
      complex_events = ComplexEvent.arel_table
      # items shared through calendars
      shared_items_from_calendars = complex_events.join(cic).on(cic[:event_id].eq(complex_events[:id]))
                               .join(sharings).on(sharings[:subject_id].eq(cic[:calendar_id])
                                                      .and(sharings[:subject_class].eq(Calendar.name))
                                                      .and(sharings[:user_id].eq(self.user_id)))
                               .project(complex_events[Arel.star]).where(complex_events[:frequency].not_eq(nil))
      # items shared directly
      shared_items = complex_events.join(sharings).on(sharings[:subject_id].eq(complex_events[:id])
                                                 .and(sharings[:subject_class].eq(Event.name))
                                                 .and(sharings[:user_id].eq(self.user_id)))
                         .project(complex_events[Arel.star])
      return Event.find_by_sql(shared_items_from_calendars.union(shared_items).to_sql)
    end

    Event.where(id: nil)
  end
end