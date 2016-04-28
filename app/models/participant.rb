class Participant < AbstractModel
  belongs_to :user
  belongs_to :participantable, polymorphic: true

  PARTICIPATION_STATUS = [PENDING = 1, ACCEPTED = 2, DECLINED = 3]
end
