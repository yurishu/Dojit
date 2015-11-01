class VotesController < ApplicationController
  before_action :load_post_and_vote

  def up_vote
    update_cache_up!
    update_vote!(1)
    redirect_to :back
  end

  def down_vote
    update_cache_down!
    update_vote!(-1)
    redirect_to :back
  end

  private

  def load_post_and_vote
    @post = Post.find(params[:post_id])
    @vote = @post.votes.where(user_id: current_user.id).first
  end

  def update_vote!(new_value)
    if @vote
      authorize @vote, :update?
      @vote.update_attribute(:value, new_value)
    else
      @vote = current_user.votes.build(value: new_value, post: @post)
      authorize @vote, :create?
      @vote.save
    end
  end

  def update_cache_up!
    if(@vote && @vote.value == -1)
      $redis.incrby("post_#{@post.id}_votes_up", 1)
      $redis.incrby("post_#{@post.id}_votes_down", -1)
      $redis.incrby("post_#{@post.id}_votes", 2)
    else
      $redis.incrby("post_#{@post.id}_votes_up", 1)
      $redis.incrby("post_#{@post.id}_votes", 1)
    end
  end

  def update_cache_down!
    if(@vote && @vote.value == 1)
      $redis.incrby("post_#{@post.id}_votes_down", 1)
      $redis.incrby("post_#{@post.id}_votes_up", -1)
      $redis.incrby("post_#{@post.id}_votes", -2)
    else
      $redis.incrby("post_#{@post.id}_votes_down", 1)
      $redis.incrby("post_#{@post.id}_votes", -1)
    end
  end
end
