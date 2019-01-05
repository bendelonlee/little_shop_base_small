FactoryBot.define do
  factory :discount do
    user
    sequence(:value_off) { |n| 5 + n }
    sequence(:min_amount) { |n| 10 + n * 10 }
    discount_type { 0 }
  end
end
