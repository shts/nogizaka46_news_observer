class News < ActiveRecord::Migration
  def up
    create_table :articles do |t|
      t.string  :url
      t.timestamps null: false
    end
  end

  def down
    drop_table :articles
  end
end
