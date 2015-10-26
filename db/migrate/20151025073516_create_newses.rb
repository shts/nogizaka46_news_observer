class CreateNewses < ActiveRecord::Migration
  def change
    create_table :newses do |t|
      t.string :url
    end
  end
end
