class AddOptionsToServices < ActiveRecord::Migration
  def self.up
    add_column :services, :option, :string
  end

  def self.down
    remove_column :services, :option
  end
end
