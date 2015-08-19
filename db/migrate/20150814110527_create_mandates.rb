class CreateMandates < ActiveRecord::Migration
  def change
    create_table :mandates do |t|
      t.references :customer_bank_account, index: true
      t.string :reference
      t.string :status
      t.string :scheme
      t.date :next_possible_charge_date
      t.string :gc_id, index: true
      t.datetime :gc_created_at

      t.timestamps
    end
  end
end
