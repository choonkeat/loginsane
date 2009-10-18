class CreateSites < ActiveRecord::Migration
  def self.up
    create_table :sites do |t|
      t.string :name
      t.string :slug
      t.string :key
      t.string :secret
      t.string :callback_url
      t.text :css

      t.timestamps
    end
    add_index :sites, :slug
  end

  def self.down
    drop_table :sites
  end
end
