class Participation < AbstractModel
  belongs_to :user
  belongs_to :participationable, polymorphic: true
  belongs_to :sender, class_name: 'User', foreign_key: 'sender_id'

  PARTICIPATION_STATUS = [PENDING = 1, ACCEPTED = 2, DECLINED = 3]

  validates :user_id, allow_blank: true, numericality: {only_integer: true}
  validates :email, length: {maximum: 128}, allow_blank: true,
            email_format: {:message => "doesn't look like an email address."}
end
