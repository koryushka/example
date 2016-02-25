class Calendar < ActiveRecord::Base
  belongs_to :user
  has_and_belongs_to_many :calendar_items
  has_and_belongs_to_many :calendars_groups

  validates :title, length: {maximum: 128}, presence: true
  validates :hex_color, length: {maximum: 6}
  validates :main, allow_blank: true, inclusion: {in: [true, false]}
  validates :kind, allow_blank: true, numericality: {only_integer: true}
  validates :visible, allow_blank: true, inclusion: {in: [true, false]}

  def shared_items
    if self.main?
      cic = Arel::Table.new(:calendar_items_calendars)
      sharings = SharingPermission.arel_table
      items = CalendarItem.arel_table
      # items shared through calendars
      shared_items_from_calendars = items.join(cic).on(cic[:calendar_item_id].eq(items[:id]))
                               .join(sharings).on(sharings[:subject_id].eq(cic[:calendar_id])
                                                      .and(sharings[:subject_class].eq(Calendar.name))
                                                      .and(sharings[:user_id].eq(self.user_id)))
                               .project(items[Arel.star])
      # items shared directly
      shared_items = items.join(sharings).on(sharings[:subject_id].eq(items[:id])
                                                 .and(sharings[:subject_class].eq(CalendarItem.name))
                                                 .and(sharings[:user_id].eq(self.user_id)))
                         .project(items[Arel.star])
      CalendarItem.find_by_sql(shared_items_from_calendars.union(shared_items).to_sql)
    end
  end
end