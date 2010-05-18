require 'test_helper'

class CommentTest < ActiveSupport::TestCase
  should_validate_presence_of :body
  # should_ensure_length_in_range :body, 1...1240
  should_belong_to :user
end
