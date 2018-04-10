class ReviewAction < ApplicationRecord
  has_many :reviews
  has_many :posts, :through => :reviews

  validates :name, :presence => true
  validates :short_name, :presence => true, :uniqueness => true
end
