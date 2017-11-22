require "bundler/setup"
require "fortify"
require "pry"
require "pry-byebug"
require "database_cleaner"

RSpec.configure do |config|
  load "support/schema.rb"
  require "support/models.rb"
  load "support/fixtures.rb"
  require "support/policies.rb"
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  DatabaseCleaner.strategy = :transaction
  config.before(:each) { DatabaseCleaner.start }
  config.after(:each) { DatabaseCleaner.clean }
end
