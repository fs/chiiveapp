module CommentsHelper


  def get_comment_path(comment)
    if (comment.commentable_type == "Post")
      user_socail_set_post_comment_path(comment.user, comment.commentable.social_set, comment.commentable, comment) 
    else
      user_socail_set_comment_path(comment.user, comment.commentable.social_set, comment) 
    end
  end
  def get_comment_edit_path(comment)
    if (comment.commentable_type == "Post")
      edit_user_socail_set_post_comment_path(comment.user, comment.commentable.socail_set, comment.commentable, comment) 
    else
      edit_user_socail_set_comment_path(comment.user, comment.commentable.social_set, comment) 
    end
  end

  def get_commentable_path(comment)
    if (comment.commentable_type == "Post")
      user_socail_set_post_path(comment.user, comment.commentable.socail_set, comment.commentable) 
    else
      user_socail_set_path(comment.user, comment.commentable.social_set) 
    end
  end

end
