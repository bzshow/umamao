class Flag
  include MongoMapper::Document
  COMMON_TYPES = Set.new(%w[spam offensive attention not_relevant])
  QUESTION_TYPES = COMMON_TYPES
  ANSWER_TYPES = COMMON_TYPES
  SEARCH_RESULT_TYPES = COMMON_TYPES | 'broken_link'
  ALL_TYPES = QUESTION_TYPES | ANSWER_TYPES | SEARCH_RESULT_TYPES
  key :type, String, :required => true

  key :_id, String
  key :user_id, String
  belongs_to :user

  key :group_id, String
  belongs_to :group

  key :flaggeable_id, String
  key :flaggeable_type, String
  belongs_to :flaggeable, :polymorphic => true

  validates_presence_of :user_id, :flaggeable_id, :flaggeable_type
  validates_inclusion_of :type, :within => ALL_TYPES

  validate :should_be_unique
  validate :check_reputation

  timestamps!

  protected
  def should_be_unique
    flag = Flag.first({ :flaggeable_type => self.flaggeable_type,
                        :flaggeable_id => self.flaggeable_id,
                        :user_id     => self.user_id
                       })

    valid = (flag.nil? || flag.id == self.id)
    if !valid
      self.errors.add(:flagged, "You already flagged this #{self.flaggeable_type}")
    end
  end

  def check_reputation
    unless user.can_vote_up_on?(self.flaggeable.group)
      reputation = self.flaggeable.group.reputation_constrains["flag"]
      self.errors.add(:reputation, I18n.t("users.messages.errors.reputation_needed",
                                          :min_reputation => reputation,
                                          :action => I18n.t("users.actions.flag")))
      return false
    end
    return true
  end
end
