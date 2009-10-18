class CreateServices < ActiveRecord::Migration
  def self.up
    create_table :services do |t|
      t.integer :site_id
      t.string :name
      t.string :icon
      t.string :key
      t.string :secret
      t.string :auth_type

      t.timestamps
    end
  end

  def self.down
    drop_table :services
  end
end
