class AddQuestionIdToPosts < ActiveRecord::Migration[5.1]
  def change
    add_column :posts, :question_id, :integer

    Post.all.each do |post|
      id = post.link.split('/')[-1].to_i
      post.answer_id = id
      post.save!
    end
  end
end
