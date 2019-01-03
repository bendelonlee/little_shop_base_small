FactoryBot.define do
  factory :order_item do
    order
    item
    sequence(:quantity) { |n| ("#{n}".to_i+1)*2 }
    sequence(:price) { |n| ("#{n}".to_i+1)*1.5 }
    fulfilled { false }
    amount_discounted { 0 }
  end
  factory :fulfilled_order_item, parent: :order_item do
    fulfilled { true }
  end
end
