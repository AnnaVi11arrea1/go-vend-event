module CommentHelper
  def delete_comment_path(comment)
    event_comment_path(comment.event, comment)
  end
end
