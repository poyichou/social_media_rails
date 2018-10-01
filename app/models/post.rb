class Post < ApplicationRecord
  belong_to :user
  validates_presence_of :content
end
