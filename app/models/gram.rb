class Gram < ActiveRecord::Base
  belongs_to :user
  validates :message, presence: true, length: { minimum: 3 }

  mount_uploader :picture, PictureUploader
end
