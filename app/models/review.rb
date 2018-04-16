class Review < ApplicationRecord
  belongs_to :post
  belongs_to :review_action
  belongs_to :user

  validates :post, :presence => true
  validates :review_action, :presence => true
  validates :user, :presence => true

  def text_class
    if review_action.short_name == "vtc"
      return "text-danger"
    elsif review_action.short_name == "skp"
      return "text-info"
    else
      return "text-warning"
    end
  end
end
