require 'factory_bot_rails'

include FactoryBot::Syntax::Methods

OrderItem.destroy_all
Order.destroy_all
Item.destroy_all
Discount.destroy_all
User.destroy_all


admin = create(:admin)
user = create(:user)
merchant_1 = create(:merchant)
merchant_2, merchant_3, merchant_4 = create_list(:merchant, 3)

inactive_merchant_1 = create(:inactive_merchant)
inactive_user_1 = create(:inactive_user)

item_1 = create(:item, user: merchant_1)
item_2 = create(:item, user: merchant_2)
item_3 = create(:item, user: merchant_3)
item_4 = create(:item, user: merchant_4)


discount_1 = create(:discount, user: merchant_1)
discount_2 = create(:discount, user: merchant_2)
discount_3 = create(:discount, user: merchant_3)
discount_4 = create(:discount, user: merchant_4)

create_list(:item, 10, user: merchant_1)

inactive_item_1 = create(:inactive_item, user: merchant_1)
inactive_item_2 = create(:inactive_item, user: inactive_merchant_1)

Random.new_seed
rng = Random.new

amounts = ((0..9).to_a + (1..5).to_a * 2 + (1..3).to_a * 3 + [21])
quantity_amounts = amounts.reject{|n| n == 0}.shuffle.cycle
amounts = amounts.cycle

Item.all.each do |item|
  amounts.next.times do
    ordered_at = rand(24).months.ago + rand(30).days + rand(86400).seconds
    fulfilled_at = ordered_at + amounts.next.days + rand(86400).seconds
    amounts.next.times do
      order = create(:completed_order, user: user)
      amounts.next.times do
        create(:fulfilled_order_item, order: order, item: item, price: item.price, quantity: quantity_amounts.next, created_at: ordered_at, updated_at: fulfilled_at)
      end
    end
  end
end

order = create(:order, user: user)
create(:order_item, order: order, item: item_1, price: 1, quantity: 1)
create(:fulfilled_order_item, order: order, item: item_2, price: 2, quantity: 1, created_at: rng.rand(23).days.ago, updated_at: rng.rand(23).hours.ago)

order = create(:cancelled_order, user: user)
create(:order_item, order: order, item: item_2, price: 2, quantity: 1, created_at: rng.rand(23).hour.ago, updated_at: rng.rand(59).minutes.ago)
create(:order_item, order: order, item: item_3, price: 3, quantity: 1, created_at: rng.rand(23).hour.ago, updated_at: rng.rand(59).minutes.ago)
