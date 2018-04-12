class Post < ApplicationRecord
  has_and_belongs_to_many :reasons
  has_one :post_log, dependent: :destroy
  has_many :flags, dependent: :destroy
  has_many :reviews, dependent: :destroy
  belongs_to :site

  validates :title, :presence => true
  validates :body, :presence => true
  validates :link, :presence => true, :uniqueness => true
  validates :post_creation_date, :presence => true
  validates :user_link, :presence => true
  validates :username, :presence => true
  validates :user_reputation, :presence => true
  validates :likelihood, :presence => true
  validate :question_id_exists

  def next
    Post.where("id > ?", self.id).first
  end

  private
    def question_id_exists
      unless self.question_id.present?
        errors.add(:question_id, "must be present")
      end
    end 
end
