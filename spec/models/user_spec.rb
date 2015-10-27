require 'rails_helper'

describe User do

  include TestFactories

  before do
    @user = authenticated_user
    @post_fav = associated_post
    @post_not_fav = associated_post
    @favorite = @user.favorites.build(post: @post_fav)
    @favorite.save
  end

  describe "#favorited(post)" do
    it "returns `nil` if the user has not favorited the post" do
      expect( @user.favorited(@post_not_fav) ).to eq(nil)
    end

    it "returns the appropriate favorite if it exists" do
      expect( @user.favorited(@post_fav) ).to eq(@favorite)
    end
  end
end
