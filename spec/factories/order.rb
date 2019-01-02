FactoryBot.define do
  factory :order do
    user
    status { :pending }
  end
  factory :completed_order, parent: :order do
    user
    status { :completed }
  end
  factory :cancelled_order, parent: :order do
    user
    status { :cancelled }
  end

  factory :discount do
    user
    sequence(:value_off) { |n| 5 + n }
    sequence(:min_amount) { |n| 10 + n * 10 }
    discount_type { 0 }
  end
end
