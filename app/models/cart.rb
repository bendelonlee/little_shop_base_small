class Cart
  attr_reader :contents

  def initialize(initial_contents)
    @contents = initial_contents || Hash.new(0)
  end

  def total_count
    @contents.values.sum
  end

  def count_of(item_id)
    @contents[item_id.to_s].to_i
  end

  def add_item(item_id)
    @contents[item_id.to_s] ||= 0
    @contents[item_id.to_s] += 1
  end

  def subtract_item(item_id)
    @contents[item_id.to_s] -= 1
    @contents.delete(item_id.to_s) if @contents[item_id.to_s] == 0
  end

  def remove_all_of_item(item_id)
    @contents.delete(item_id.to_s)
  end

  def items
    @contents.keys.map do |item_id|
      Item.includes(:user).find(item_id)
    end
  end

  def subtotal_before_discount(item_id)
    item = Item.find(item_id)
    item.price * count_of(item_id)
  end

  def subtotal(item_id)
    item = Item.find(item_id)
    order_item = OrderItem.new(item: item, price: item.price, quantity: count_of(item.id))
    order_item.set_amount_discounted
    order_item.subtotal
  end

  def grand_total
    @contents.keys.map do |item_id|
      subtotal(item_id)
    end.sum
  end

  def applicable_discount(item)
    order_item = OrderItem.new(item: item, price: item.price, quantity: count_of(item.id))
    order_item.applicable_discount
  end

  def amount_discounted(item)
    order_item = OrderItem.new(item: item, price: item.price, quantity: count_of(item.id))
    order_item.set_amount_discounted
    order_item.amount_discounted
  end
end
