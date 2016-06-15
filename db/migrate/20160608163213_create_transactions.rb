class CreateTransactions < ActiveRecord::Migration
  def change
    create_table :transactions,{:id => false} do |t|
      t.string :txn_id,:primary_key => true
      t.string :txn_type
      t.datetime :txn_date
      t.string :klass
      t.string :dept
      t.string :account_name
      t.string :vendor_name
      t.string :desc
      t.decimal :amount
      t.timestamps null: false
    end
  end
end
