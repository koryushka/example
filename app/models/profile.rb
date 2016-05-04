class Profile < AbstractModel
  belongs_to :user

  validates :first_name, length: {maximum: 64}
  validates :last_name, length: {maximum: 64}
  validates :image_url, length: {maximum: 2048}
  validates :color, length: {maximum: 6}

  default :first_name, ''
  default :last_name, ''
end