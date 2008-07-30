class CreatePeople < ActiveRecord::Migration
  def self.up
    create_table :people do |t|
      t.column :name,  :string
      t.column :plus,  :integer, :default => 0
      t.column :minus, :integer, :default => 0
    end
  end

  def self.down
    drop_table :people
  end
end
