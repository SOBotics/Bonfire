class CloseLog < ApplicationRecord
  belongs_to :post

  validates :is_closed, :presence => true
end
