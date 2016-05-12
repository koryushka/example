class GoogleAccessToken < ActiveRecord::Base
  belongs_to :user

  def expired?
    Time.now.utc >= self.expires_at
  end
end
