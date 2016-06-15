class CreateProfitLosses < ActiveRecord::Migration
  def change
    create_table :profit_losses do |t|
      t.string :txn_type
      t.integer :account_id
      t.date :txn_date
      t.string :class_name
      t.string :dept_name
      t.string :vendor
      t.string :memo
      t.float :amount

      t.timestamps null: false
    end
  end
end
