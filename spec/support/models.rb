class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
  set_fortify
end

class Project < ApplicationRecord
  has_many :project_users
  has_many :users, through: :project_users
  has_many :tasks
end

class ProjectUser < ApplicationRecord
  validates :user, presence: true
  validates :project, presence: true

  belongs_to :project
  belongs_to :user
end

class Task < ApplicationRecord
  set_fortify policy: "CustomTaskPolicy"
  belongs_to :project
  belongs_to :user
end

class User < ApplicationRecord
  has_many :project_users
  has_many :projects, through: :project_users
  has_many :tasks, through: :projects
end

class Snippet < ApplicationRecord
end
