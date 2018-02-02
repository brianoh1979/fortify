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

class CustomTaskPolicy < Fortify::Base
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
    attrs =  %i(name number text)

    can :create, *attrs
    can :read, *attrs

    if user.id == record.id
      can :update, *attrs
    end

    if user.admin?
      can :create
      can :update
      can :destroy
      scope { all }
    else
      scope { where(id: user.id) }
    end
  end
end

class SnippetPolicy < Fortify::Base
  fortify do |user, record|
  end
end
