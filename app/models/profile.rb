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