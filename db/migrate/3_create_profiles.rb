class CreateProfiles < ActiveRecord::Migration
  def self.up
    create_table :profiles do |t|
      t.integer :site_id
      t.integer :service_id
      t.string :identifier
      t.string :token
      t.datetime :lastlogin_at
      t.text :json_text

      t.timestamps
    end
    add_index :profiles, :token
  end

  def self.down
    drop_table :profiles
  end
end
