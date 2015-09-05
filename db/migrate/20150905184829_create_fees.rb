class CreateFees < ActiveRecord::Migration
  def change
    create_table :fees do |t|
      t.references :event, index: true
      t.integer :amount
      t.string :currency

      t.timestamps
    end
  end
end
