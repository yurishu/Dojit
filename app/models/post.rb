class Post < ActiveRecord::Base
  has_many :comments, dependent: :destroy
  has_many :votes, dependent: :destroy
  has_many :favorites, dependent: :destroy
  belongs_to :user
  belongs_to :topic


  default_scope { order('rank DESC') }
  scope :visible_to, -> (user) { user ? all : joins(:topic).where('topics.public' => true)}

  validates :title, length: { minimum: 5 }, presence: true
  validates :body, length: { minimum: 20 }, presence: true
  validates :topic, presence: true
  validates :user, presence: true

  def up_votes
    votes_sum = $redis.get("post_#{self.id}_votes_up")
    if votes_sum.nil?
      votes_sum = votes.where(value: 1).count
      $redis.set("post_#{self.id}_votes_up", votes_sum)
    end
    votes_sum
  end

  def down_votes
    votes_sum = $redis.get("post_#{self.id}_votes_down")
    if votes_sum.nil?
      votes_sum = votes.where(value: -1).count
      $redis.set("post_#{self.id}_votes_down", votes_sum)
    end
    votes_sum
  end

  def points
    votes_sum = $redis.get("post_#{self.id}_votes")
    if votes_sum.nil?
      votes_sum = votes.sum(:value)
      $redis.set("post_#{self.id}_votes", votes_sum)
    end
    votes_sum
  end

  def update_rank
    age_in_days = (created_at - Time.new(1970,1,1)) / (60 * 60 * 24) # 1 day in seconds
    new_rank = points.to_i + age_in_days

    update_attribute(:rank, new_rank)
  end

  def create_vote
    user.votes.create(value: 1, post: self)
  end

  def save_with_initial_vote
    ActiveRecord::Base.transaction do
      self.save
      self.create_vote
    end

  end

end
