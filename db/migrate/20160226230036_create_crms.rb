class CreateCrms < ActiveRecord::Migration
  def change
    create_table :crms do |t|
      t.string :name
      t.string :display_name

      t.timestamps
    end

    add_index :crms, :name
  end
end
