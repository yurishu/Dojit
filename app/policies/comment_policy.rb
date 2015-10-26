class CommentPolicy < ApplicationPolicy
  def create?
    user.present?
  end

  def destroy?
    can_moderate?
  end
end
