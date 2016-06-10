class GoogleChannel < ActiveRecord::Base
  belongs_to :channelable, polymorphic: true
end
