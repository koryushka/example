class GoogleAccessToken < ActiveRecord::Base
  belongs_to :user
  has_many :calendars, dependent: :destroy

  def expired?
    Time.now.utc >= self.expires_at - 3600
  end

  def unsync!
    self.update_column(:deleted, true)
    remove_calendars
  end

  def sync!
    self.update_column(:deleted, nil)
  end

  protected

  def remove_calendars
    self.calendars.destroy_all
  end
end
