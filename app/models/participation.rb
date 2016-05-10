class Participation < AbstractModel
  include Swagger::Blocks

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

  swagger_schema :ParticipationInput do
    key :type, :object
    property :user_ids do
      key :description, 'Array of users ids which should participate events lists or groups'
      key :type, :array
      items do
        key :type, :integer
      end
    end
    property :emails do
      key :description, 'Array of people emails which should participate events, lists or groups'
      key :type, :array
      items do
        key :type, :string
      end
    end
    property :message do
      key :description, 'Is not being used'
      key :type, :string
    end
  end

  swagger_schema :Participation do
    key :type, :object
    property :id do
      key :type, :integer
    end
    property :email do
      key :type, :string
      key :format, :email
      key :description, "Person's email which should participate events or lists"
    end
    property :status do
      key :description, 'Can be: PENDING = 1, ACCEPTED = 2, DECLINED = 3'
      key :type, :integer
    end
    property :kind do
      key :type, :string
      key :description, 'Type of participation: Event, List, Group'
    end
    property :message do
      key :description, 'Is not being used'
      key :type, :string
    end
    property :user do
      key :'$ref', :User
    end
    property :sender do
      key :'$ref', :User
    end
  end
end
