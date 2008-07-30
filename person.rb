require 'rubygems'
require 'activerecord'
require 'yaml'
require 'logger'

dbconfing = YAML.load_file('./db/database.yml')
ActiveRecord::Base.establish_connection(dbconfing)
ActiveRecord::Base.logger = Logger.new('./libelabot.log')

class Person < ActiveRecord::Base
  def plusplus
    self.plus += 1
    self.save
  end

  def minusminus
    self.minus += 1
    self.save
  end

  def score
    plus - minus
  end

  def print_score
    "#{name} : #{plus - minus} (#{plus}++ #{minus}--)"
  end
end
