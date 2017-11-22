class ApplicationPolicy < Fortify::Base
  def index?
    read?
  end

  def show?
    read?
  end

  def read?
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
  def permitted_attributes_for_read
    %i(id name number text)
  end

  def permitted_attributes_for_update
    %i(name text)
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
  def permitted_attributes_for_read
    %i(id name number text personal project_id user_id)
  end

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
  def permitted_attributes_for_read
    %i(id name number text)
  end

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