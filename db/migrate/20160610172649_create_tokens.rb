class CreateTokens < ActiveRecord::Migration
  def change
    create_table :tokens do |t|
      t.string :access_token
      t.string :access_secret
      t.string :company_id
      t.datetime :token_expires_at

      t.timestamps null: false
    end
  end
end
