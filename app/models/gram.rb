class Gram < ActiveRecord::Base
  belongs_to :user
  has_many :comments, dependent: :destroy

  validates :message, presence: true, length: { minimum: 3 }
  validates :picture, presence: true

  mount_uploader :picture, PictureUploader
end
