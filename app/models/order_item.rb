class OrderItem < ApplicationRecord
  belongs_to :order
  belongs_to :item
  before_validation :set_amount_discounted

  validates :price, presence: true, numericality: {
    only_integer: false,
    greater_than_or_equal_to: 0
  }

  validates :amount_discounted, presence: true, numericality: {
    only_integer: false,
    greater_than_or_equal_to: 0
  }

  validates :quantity, presence: true, numericality: {
    only_integer: true,
    greater_than_or_equal_to: 1
  }

  def self.twelve_months_revenue
    date_range = 1.year.ago.to_date.change(day: 1).. (Date.today.change(day: 1) - 1.day)
    OrderItem.select("sum(order_items.quantity * order_items.price) as revenue, date_trunc('month', order_items.updated_at) as month")
    .where(updated_at: date_range, fulfilled: true )
    .group("month")
    .order("month")
  end

  def applicable_discount
    return nil if !item || item.discounts.empty?
    order_amount = case item.discounts.first.discount_type
    when "percent"
      quantity
    when "dollar"
      undiscounted_subtotal
    end
    item.discounts.where("discounts.min_amount <= ?", order_amount)
    .order(value_off: :desc)
    .limit(1).first
  end

  def set_amount_discounted
    ad = applicable_discount
    unless ad
      self.amount_discounted = 0
      return
    end
    amount_to_discount = case ad.discount_type
    when "percent"
      0.01 * ad.value_off * undiscounted_subtotal
    when "dollar"
      ad.value_off
    end
    self.amount_discounted = amount_to_discount
  end

  def subtotal
    undiscounted_subtotal - amount_discounted
  end

  def undiscounted_subtotal
    quantity * price
  end
end
