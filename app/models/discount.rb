class Discount < ApplicationRecord
  validates_presence_of :discount_type

  validates :value_off, presence: true, numericality: {
    only_integer: true,
    greater_than_or_equal_to: 0
  }

  validates :min_amount, presence: true, numericality: {
    only_integer: true,
    greater_than_or_equal_to: 2
  }

  belongs_to :user

  enum discount_type: ["percent", "dollar"]
end
