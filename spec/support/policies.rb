class ProjectPolicy < Fortify::Base
  fortify do |user|
    can :create
    can :read, *%i(id name)
    can :read, *%i(number text)

    can :update, *%i(name text)

    if user.admin?
      can :destroy
      scope { all }
    else
      scope { joins(:project_users).where(project_users: { user_id: user.id}) }
    end
  end
end

class TaskPolicy < Fortify::Base
  fortify do |user|
    can :read
    if user.admin?
      scope { all }
    else
      scope do
        joins(project: :project_users)
          .where(project_users: { user_id: user.id })
          .where("(personal = 'f' OR (personal = 't' AND tasks.user_id = :user_id))", user_id: user.id)
      end
    end
  end
end

class UserPolicy < Fortify::Base
  fortify do |user|
    can :create
    can :read

    if user.admin?
      scope { all }
    else
      scope { where(id: user.id) }
      cannot :read, :admin
    end
  end
end
