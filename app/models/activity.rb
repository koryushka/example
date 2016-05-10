class Activity < ActiveRecord::Base
  belongs_to :notificationable, polymorphic: true
  belongs_to :user

  ACTIVITY_TYPES = [Event, List, ListItem, Group, Participation]
end
