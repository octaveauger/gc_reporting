class CreateRevenues < ActiveRecord::Migration
  def change
    create_table :revenues do |t|
      t.references :organisation, index: true
      t.string :category
      t.string :reference
      t.integer :amount
      t.string :currency

      t.timestamps
    end
    add_index :revenues, :category
    add_index :revenues, :reference
  end
end
