require 'rails_helper'

RSpec.describe Cart do
  it '.total_count' do
    cart = Cart.new({
      '1' => 2,
      '2' => 3
    })
    expect(cart.total_count).to eq(5)
  end

  it '.count_of' do
    cart = Cart.new({})
    expect(cart.count_of(5)).to eq(0)

    cart = Cart.new({
      '2' => 3
    })
    expect(cart.count_of(2)).to eq(3)
  end

  it '.add_item' do
    cart = Cart.new({
      '1' => 2,
      '2' => 3
    })

    cart.add_item(1)
    cart.add_item(2)
    cart.add_item(3)

    expect(cart.contents).to eq({
      '1' => 3,
      '2' => 4,
      '3' => 1
      })
  end

  it '.subtract_item' do
    cart = Cart.new({
      '1' => 2,
      '2' => 3
    })

    cart.subtract_item(1)
    cart.subtract_item(1)
    cart.subtract_item(2)

    expect(cart.contents).to eq({
      '2' => 2
      })
  end

  it '.remove_all_of_item' do
    cart = Cart.new({
      '1' => 2,
      '2' => 3
    })

    cart.remove_all_of_item(1)

    expect(cart.contents).to eq({
      '2' => 3
    })
  end

  it '.items' do
    item_1, item_2 = create_list(:item, 2)
    cart = Cart.new({})
    cart.add_item(item_1.id)
    cart.add_item(item_2.id)

    expect(cart.items).to eq([item_1, item_2])
  end

  it '.subtotal_before_discount' do
    item_1 = create(:item)
    discount = create(:discount, user: item_1.user, min_amount: 2)
    cart = Cart.new({})
    cart.add_item(item_1.id)
    cart.add_item(item_1.id)
    cart.add_item(item_1.id)

    expect(cart.subtotal_before_discount(item_1.id)).to eq(item_1.price * cart.total_count)
  end

  it '.subtotal' do
    item_1 = create(:item)
    discount = create(:discount, user: item_1.user, min_amount: 2)
    cart = Cart.new({})
    cart.add_item(item_1.id)
    cart.add_item(item_1.id)
    cart.add_item(item_1.id)

    expect(cart.subtotal(item_1.id)).to eq(item_1.price * cart.total_count - cart.amount_discounted(item_1))
  end

  it '.grand_total' do
    item_1, item_2 = create_list(:item, 2)
    cart = Cart.new({})
    cart.add_item(item_1.id)
    cart.add_item(item_1.id)
    cart.add_item(item_2.id)
    cart.add_item(item_2.id)
    cart.add_item(item_2.id)

    expect(cart.grand_total).to eq(cart.subtotal(item_1.id) + cart.subtotal(item_2.id))
  end

  it 'applicable_discount' do
    cart = Cart.new({})
    item_1, item_2 = create_list(:item, 2)
    merchant = item_1.user
    discount = create(:discount, user: merchant, min_amount: 10, discount_type: 'percent', value_off: 10)
    other_discount = create(:discount, min_amount: 5, discount_type: 'percent', value_off: 20)

    cart.add_item(item_1.id)
    10.times do
      cart.add_item(item_1.id)
    end
    expect(cart.applicable_discount(item_1)).to eq(discount)
  end

  it '.amount_discounted' do
    cart = Cart.new({})
    merchant = create(:merchant)
    item_1 = create(:item, price: 7, user: merchant)
    discount = create(:discount, user: merchant, min_amount: 10, discount_type: 'percent', value_off: 10)

    10.times do
      cart.add_item(item_1.id)
    end
    expect(cart.amount_discounted(item_1)).to eq(7)
  end
end
