class List < AbstractModel
  include Swagger::Blocks

  belongs_to :user
  has_many :list_items, dependent: :destroy
  has_many :events
  has_many :participations, as: :participationable, dependent: :destroy
  has_many :activities, as: :notificationable, dependent: :destroy

  LIST_KINDS = [GROCERY = 1, TODO = 2]

  validates :title, length: {maximum: 128}, presence: true
  validates :notes, length: {maximum: 2048}, exclusion: { in: [nil] }
  validates :kind, numericality: {only_integer: true}, inclusion: {in: LIST_KINDS}

  default :public, true

  @changed_attributes = nil
  before_save do
    @changed_attributes = changes
  end

  after_save do
    next unless @changed_attributes.present?

    family = user.family
    if public? && family.present?
      user.family.participations.pluck(:user_id).each do |user_id|
        PubnubHelper::Publisher.publish(@changed_attributes, user_id)
      end
      PubnubHelper::Publisher.publish(@changed_attributes, user.family.owner.id)
    else
      PubnubHelper::Publisher.publish(@changed_attributes, user_id)
    end

    @changed_attributes = nil
  end

  swagger_schema :List do
    key :type, :object
    property :id do
      key :type, :string
      key :description, 'List ID'
    end
    property :title do
      key :type, :string
      key :description, 'List title'
    end
    property :user_id do
      key :type, :string
      key :description, 'User ID who created this list'
    end
    property :notes do
      key :type, :string
      key :description, 'Additional notes'
    end
    property :kind do
      key :type, :integer
      key :description, 'Specified type of list. Can be 1 - Grocery, 2 - ToDo'
    end
    property :items do
      key :type, :array
      items do
        key :'$ref', :ListItem
      end
    end
    property :participations do
      key :type, :array
      items do
        key :'$ref', :Participation
      end
    end
  end

  swagger_schema :ListInput do
    key :type, :object
    key :required, %w(title)
    property :title do
      key :type, :string
      key :description, 'List title'
      key :maxLength, 128
    end
    property :notes do
      key :type, :string
      key :description, 'Additional notes'
      key :maxLength, 2048
    end
    property :kind do
      key :type, :integer
      key :description, 'Specified type of list. Can be 1 - Grocery, 2 - ToDo'
    end
  end

  swagger_schema :ArrayOfLists do
    key :type, :array
    items do
      key :'$ref', :List
    end
  end
end
