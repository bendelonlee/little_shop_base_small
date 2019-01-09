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
    ordered_at = rand(24).months.ago + rand(10..40).days + rand(86400).seconds
    fulfilled_at = ordered_at + rand(10).days + rand(86400).seconds
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


User.where(role: :merchant).all.each do |merchant|
  created_at = rand(10..20).days.ago + rand(86400).seconds
  dis_amount = [5,10,25].sample
  d_type = ["percent", "dollar"].sample
  case d_type
  when "dollar"
    value_off = dis_amount / 5
  when "percent"
    value_off = dis_amount
  end
  discount = create( :discount, user: merchant, min_amount: dis_amount, value_off: value_off, created_at: created_at, discount_type: d_type)
  7.times do
    item = merchant.items.sample

    ordered_at = created_at + rand(86400)
    fulfilled_at = ordered_at + rand(8640).seconds
    create(:fulfilled_order_item, order: order, item: item, price: item.price, quantity: discount.min_amount, created_at: ordered_at, updated_at: fulfilled_at)
  end
end

# OrderItem.where("updated_at > ?", Time.now).destroy_all
