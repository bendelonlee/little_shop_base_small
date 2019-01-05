class OrderItem < ApplicationRecord
  belongs_to :order
  belongs_to :item

  validates :price, presence: true, numericality: {
    only_integer: false,
    greater_than_or_equal_to: 0
  }
  validates :quantity, presence: true, numericality: {
    only_integer: true,
    greater_than_or_equal_to: 1
  }

  def self.last_years_sales_by_month
    date_range = 1.year.ago.to_date.change(day: 1).. (Date.today.change(day: 1) - 1.day)
    OrderItem.select("sum(order_items.quantity * order_items.price) as revenue, date_trunc('month', order_items.updated_at) as month")
    .where(updated_at: date_range, fulfilled: true )
    .group("month")
    .order("month")
  end

  def subtotal
    quantity * price
  end
end
