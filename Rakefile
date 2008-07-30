require 'rubygems'
require 'active_record'

dbconfig = YAML.load_file('./db/database.yml')
ActiveRecord::Base.establish_connection(dbconfig)

require 'logger'
ActiveRecord::Base.logger = Logger.new('./db/migrate.log')

task :migrate do
  ActiveRecord::Migrator.migrate('db/migrate', ENV['VERSION'] ? ENV['VERSION'].to_i : nil)
end
