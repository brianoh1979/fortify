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
      scope { user.projects }
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
        user.tasks.where("(personal = 'f' OR (personal = 't' AND tasks.user_id = :user_id))", user_id: user.id)
      end
    end
  end
end

class UserPolicy < Fortify::Base
  fortify do |user, record|
    can :create
    can :read

    if user == record
      can :update
    end

    if user.admin?
      scope { all }
    else
      scope { where(id: user.id) }
      cannot :read, :admin
    end
  end
end
