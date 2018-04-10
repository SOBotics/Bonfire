class Review < ApplicationRecord
  belongs_to :post
  belongs_to :review_action
  belongs_to :user

  validates :post, :presence => true
  validates :review_action, :presence => true
  validates :user, :presence => true
end
