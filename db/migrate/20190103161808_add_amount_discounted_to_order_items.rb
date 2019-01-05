class AddAmountDiscountedToOrderItems < ActiveRecord::Migration[5.1]
  def change
    add_column :order_items, :amount_discounted, :decimal
  end
end
