class CreatePaymentEvents < ActiveRecord::Migration
  def change
    create_table :payment_events do |t|
      t.references :payment, index: true
      t.string :action
      t.string :origin
      t.string :cause
      t.text :description
      t.string :scheme
      t.string :reason_code
      t.string :gc_id, index: true

      t.timestamps
    end
  end
end
