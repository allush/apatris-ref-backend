class CreateUsers < ActiveRecord::Migration[6.1]
  def change
    create_table :users do |t|
      t.string :address, null: false
      t.references :inviter, reference: :user, index: true
      t.string :invite_code

      t.timestamps
    end
  end
end
