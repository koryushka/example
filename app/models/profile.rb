class Profile < AbstractModel
  belongs_to :user

  validates :full_name, length: {maximum: 64}
  validates :image_url, length: {maximum: 2048}
  validates :color, length: {maximum: 6}
end