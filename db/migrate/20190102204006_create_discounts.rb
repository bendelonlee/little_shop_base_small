class CreateDiscounts < ActiveRecord::Migration[5.1]
  def change
    create_table :discounts do |t|
      t.references :user, foreign_key: true

      t.integer :discount_type
      t.integer :value_off
      t.integer :min_amount

      t.timestamps
    end
  end
end
