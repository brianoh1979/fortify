Fortify.insecurely do
  #USERS
  default_user = User.create!(name: "default-user", text: "This is the default user")
  partner_user = User.create!(name: "partner-user", text: "This is the partner user")
  other_user = User.create!(name: "other-user", text: "This is another user")
  admin_user = User.create!(name: "admin-user", admin: true, text: "This is the admin user")

  #PROJECTS
  default_project = Project.create!(name: "Default Project", text: "This is the default project", number: 999)
  other_project = Project.create!(name: "Another Project", text: "This is another project", number: 123)

  #TASKS
  default_task = Task.create!(project: default_project, name: "Default Task", text: "This is the default task")
  personal_task = Task.create!(project: default_project, name: "Personal Task", personal: true, user: default_user, text: "This is the personal task")
  other_task = Task.create!(project: other_project, name: "Another Task", text: "This is another task")

  #PROJECT USERS
  ProjectUser.create!(user: default_user, project: default_project)
  ProjectUser.create!(user: partner_user, project: default_project)
  ProjectUser.create!(user: other_user, project: other_project)
end
