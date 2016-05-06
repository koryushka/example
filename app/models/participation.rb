class Participation < AbstractModel
  belongs_to :user
  belongs_to :participationable, polymorphic: true
  belongs_to :sender, class_name: 'User', foreign_key: 'sender_id'
  has_many :activities, as: :notificationable

  PARTICIPATION_STATUS = [PENDING = 1, ACCEPTED = 2, DECLINED = 3]

  validates :user_id, allow_blank: true, numericality: {only_integer: true}
  validates :email, length: {maximum: 128}, allow_blank: true,
            email_format: {message: "doesn't look like an email address."}

  after_create do
    change_status_to(PENDING)
  end

  def pending?
    status == PENDING
  end

  def accepted?
    status == ACCEPTED
  end

  def declined?
    status == DECLINED
  end

  def change_status_to(status)
    update(status: status)

    activity = nil

    if pending? && user.present?
      activity = Activity.new(notificationable: self,
                              user: user,
                              activity_type: status)
    elsif !pending?
      # sending notification about invitation acceptance to inviter
      activity = Activity.new(notificationable: self,
                              user: sender,
                              activity_type: status)
    end

    activities << activity unless activity.nil?
  end
end
