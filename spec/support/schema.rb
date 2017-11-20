require "active_record"

ActiveRecord::Base.establish_connection adapter: "sqlite3", database: ":memory:"

ActiveRecord::Schema.define do
  self.verbose = false
  
  create_table :projects do |t|
    t.string :name
    t.integer :number
    t.text :text

    t.timestamps
  end

  create_table :tasks do |t|
    t.string :name
    t.integer :number
    t.text :text
    t.boolean :personal, default: false
    t.belongs_to :project
    t.belongs_to :user

    t.timestamps
  end

  create_table :users do |t|
    t.string :name
    t.integer :number
    t.text :text
    t.boolean :admin, default: false

    t.timestamps
  end

  create_table :project_users do |t|
    t.integer :project_id
    t.integer :user_id

    t.timestamps
    t.index ["project_id"], name: "index_project_users_on_project_id"
    t.index ["user_id", "project_id"], name: "index_project_users_on_user_id_and_project_id", unique: true
    t.index ["user_id"], name: "index_project_users_on_user_id", unique: true
  end
end