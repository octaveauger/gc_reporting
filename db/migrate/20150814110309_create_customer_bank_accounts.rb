class CreateCustomerBankAccounts < ActiveRecord::Migration
  def change
    create_table :customer_bank_accounts do |t|
      t.references :customer, index: true
      t.string :account_holder_name
      t.string :country_code
      t.string :currency
      t.string :bank_name
      t.boolean :enabled
      t.string :gc_id, index: true
      t.datetime :gc_created_at

      t.timestamps
    end
  end
end
