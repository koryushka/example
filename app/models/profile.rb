class Profile < AbstractModel
  include Swagger::Blocks
  belongs_to :user

  validates :first_name, length: {maximum: 64}
  validates :last_name, length: {maximum: 64}
  validates :image_url, length: {maximum: 2048}
  validates :color, length: {maximum: 6}
  validates :notification_time, numericality: {only_integer: true, greater_than: 0}, allow_blank: true

  default :first_name, ''
  default :last_name, ''
  default :notification_time, 30

  @changed_attributes = nil
  before_save do
    @changed_attributes = changes
  end

  after_save do
    next unless @changed_attributes.present?

    user_ids = []
    if [:color, :image_url, :first_name, :last_name].any? { |k| !@changed_attributes.key?(k) }
      user_ids << user_id # Me

      # My Family Members & My Family Creator
      family = user.family
      user_ids << user.family.members.pluck(:id) if family.present?

      # All other users participated (accepted) or owned events where I'm a participant (pending, accepted)
      events_ids = Participation.events
                       .where(user_id: user_id, status: [Participation::PENDING, Participation::PENDING])
                       .select(:participationable_id)
      user_ids << Event.where(id: events_ids).pluck(:user_id)
      events_paticipants_ids = Participation.events.select(:user_id)
                                   .where(participationable_id: events_ids,
                                          status: [Participation::PENDING, Participation::PENDING])
      user_ids << events_paticipants_ids.pluck(:user_id)
      user_ids.flatten.uniq.each do |user_id|
        PubnubHelper::Publisher.publish(@changed_attributes, user_id)
      end
    end

    @changed_attributes = nil
  end

  swagger_schema :Profile do
    key :type, :object
    property :id do
      key :type, :integer
    end
    property :user_id do
      key :type, :integer
    end
    property :first_name do
      key :type, :string
    end
    property :last_name do
      key :type, :string
    end
    property :image_url do
      key :type, :string
      key :description, 'Avatar URL'
    end
    property :color do
      key :type, :string
      key :description, 'Hex string representation of color'
    end
    property :notification_time do
      key :type, :integer
      key :default, 30
      key :description, 'Default time in minutes which is being used for detemining
when event occurence notifications should be sent. Default value is 30 minutes before event occurs.'
    end
  end

  swagger_schema :ProfileInput do
    key :type, :object
    property :first_name do
      key :type, :string
      key :maxLength, 64
    end
    property :last_name do
      key :type, :string
      key :maxLength, 64
    end
    property :image_url do
      key :type, :string
      key :description, 'Avatar URL'
      key :maxLength, 2048
    end
    property :color do
      key :type, :string
      key :description, 'Hex string representation of color'
      key :maxLength, 6
    end
  end

end