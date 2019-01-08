class Discount < ApplicationRecord
  validates_presence_of :discount_type, :value_off, :min_amount

  validates_with DiscountValidator

  validates :value_off, numericality: {
    only_integer: true,
    greater_than_or_equal_to: 0
  }

  validates :min_amount, numericality: {
    only_integer: true,
    greater_than_or_equal_to: 2
  }

  belongs_to :user
  enum discount_type: ["percent", "dollar"]

end
