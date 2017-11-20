class Project < ActiveRecord::Base
  has_many :project_users
  has_many :users, through: :project_users
  has_many :tasks
end

class ProjectUser < ActiveRecord::Base
  validates :user, presence: true
  validates :project, presence: true

  belongs_to :project
  belongs_to :user
end

class Task < ActiveRecord::Base
  belongs_to :project
  belongs_to :user
end

class User < ActiveRecord::Base
  has_many :project_users
  has_many :projects, through: :project_users
  has_many :tasks
end