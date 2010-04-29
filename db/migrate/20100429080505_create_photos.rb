class CreatePhotos < ActiveRecord::Migration
  def self.up
    create_table :photos do |t|
      t.references :user
      t.string :image_url
      t.string :thumb_url

      t.timestamps
    end
  end

  def self.down
    drop_table :photos
  end
end
