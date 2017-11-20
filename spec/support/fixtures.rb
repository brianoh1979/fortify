#USERS
default_user = User.create!(name: "default-user")
partner_user = User.create!(name: "partner-user")
other_user = User.create!(name: "other-user")
admin_user = User.create!(name: "admin-user", admin: true)

#PROJECTS
default_project = Project.create!(name: "Default Project")
other_project = Project.create!(name: "Another Project")

#TASKS
default_task = Task.create!(project: default_project, name: "Default Task")
personal_task = Task.create!(project: default_project, name: "Personal Task", personal: true, user: default_user)
other_task = Task.create!(project: other_project, name: "Another Task")

#PROJECT USERS
ProjectUser.create!(user: default_user, project: default_project)
ProjectUser.create!(user: partner_user, project: default_project)
ProjectUser.create!(user: other_user, project: other_project)