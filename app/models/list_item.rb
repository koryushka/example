class ListItem < AbstractModel
  include Swagger::Blocks

  belongs_to :list
  belongs_to :user
  has_many :activities, as: :notificationable

  validates :title, length: {maximum: 128}, presence: true
  validates :notes, length: {maximum: 2048}
  validates :done, allow_blank: true, inclusion: {in: [true, false]}
  validates :order, allow_blank: true, numericality: {only_integer: true}

  default :notes, ''
  default :done, false
  default :order, 0

  @changed_attributes = nil
  before_save do
    @changed_attributes = changes
  end

  after_save do
    next unless @changed_attributes.present?

    family = user.family
    if list.public? && family.present?
      user.family.participations.pluck(:user_id).each do |user_id|
        PubnubHelpers::Publisher.publish(@changed_attributes, user_id)
      end
      PubnubHelpers::Publisher.publish(@changed_attributes, user.family.owner.id)
    else
      PubnubHelpers::Publisher.publish(@changed_attributes, user_id)
    end

    @changed_attributes = nil
  end

  swagger_schema :ListItem do
    key :type, :object
    property :id do
      key :type, :integer
      key :description, 'List item ID'
    end
    property :title do
      key :type, :string
      key :description, 'List item title'
    end
    property :notes do
      key :type, :string
      key :description, 'Additional notes'
    end
    property :order do
      key :type, :integer
      key :format, :int16
      key :description, 'Sorting order for item in the list'
      key :default, 0
    end
    property :done do
      key :type, :boolean
      key :description, 'Shows whether user finished with this item or not'
      key :default, false
    end
  end

  swagger_schema :ArrayOfListItems do
    key :type, :array
    items do
      key :'$ref', :ListItem
    end
  end

  swagger_schema :ListItemInput do
    key :type, :object
    key :required, [:title]
    property :title do
      key :type, :string
      key :description, 'List item title'
      key :maxLength, 128
    end
    property :notes do
      key :type, :string
      key :description, 'Additional notes'
      key :maxLength, 2048
    end
    property :order do
      key :type, :integer
      key :format, :int16
      key :description, 'Sorting order for item in the list'
      key :default, 0
    end
    property :done do
      key :type, :boolean
      key :description, 'Shows whether user finished with this item or not'
      key :default, false
    end
  end

end
