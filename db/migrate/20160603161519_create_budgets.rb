class CreateBudgets < ActiveRecord::Migration
  def change
    create_table :budgets do |t|
      t.string :name, limit: 255
      t.integer :parent_id, limit:11
      t.integer :order_id,limit:11
      t.boolean :is_account,limit:1
      t.timestamps null: false
    end
  end
end
