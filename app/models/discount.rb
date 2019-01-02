class Discount < ApplicationRecord
  validates_presence_of :value_off
  validates_presence_of :min_amount
  validates_presence_of :discount_type

  belongs_to :user

  enum discount_type: ["percent", "dollar"]
end
