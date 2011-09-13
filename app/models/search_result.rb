class SearchResult
  include MongoMapper::Document
  include Support::Voteable

  key :_id, String
  key :_type, String
  key :url, String, :required => true
  key :title, String
  key :summary, String
  key :user_id, String, :index => true
  key :question_id, String, :index => true
  key :group_id, String, :index => true

  timestamps!

  belongs_to :group
  belongs_to :user
  belongs_to :question
end
