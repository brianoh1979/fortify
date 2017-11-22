class ApplicationPolicy < Fortify::Base
  def index?
    true
  end

  def show?
    true
  end

  def create?
    user.admin?
  end

  def new?
    create?
  end

  def update?
    true
  end

  def edit?
    update?
  end

  def destroy?
    user.admin?
  end
end

class ProjectPolicy < ApplicationPolicy
  def permitted_attributes_on_update
    [:name, :text]
  end

  class Scope < Scope
    def resolve
      if user.admin?
        scope.all
      else
        scope.joins(:project_users).where(project_users: { user_id: user.id})
      end
    end
  end
end

class TaskPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      if user.admin?
        scope.all
      else
        scope
          .joins(project: :project_users)
          .where(project_users: { user_id: user.id })
          .where("(personal = 'f' OR (personal = 't' AND tasks.user_id = :user_id))", user_id: user.id)
      end
    end
  end
end

class UserPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      if user.admin?
        scope.all
      else
        scope.where(id: user.id)
      end
    end
  end
end