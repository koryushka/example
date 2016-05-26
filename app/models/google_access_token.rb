class GoogleAccessToken < ActiveRecord::Base
  belongs_to :user
  has_many :calendars, dependent: :destroy

  def expired?
    Time.now.utc >= self.expires_at# - 3600
  end

  def unsync!
    self.update_column(:synchronizable, false)
    remove_calendars
  end

  def sync!
    self.update_column(:synchronizable, true)
  end

  def revoke!
    self.update_columns(revoked: true)
  end

  def remove_calendars
    self.calendars.destroy_all
  end

  protected

  def revoked?
    self.revoked
  end
end
