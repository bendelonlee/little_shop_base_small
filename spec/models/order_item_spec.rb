require 'rails_helper'

RSpec.describe OrderItem, type: :model do
  describe 'validations' do
    it { should validate_presence_of :price }
    it { should validate_numericality_of(:price).is_greater_than_or_equal_to(0) }
    it { should validate_presence_of :quantity }
    it { should validate_numericality_of(:quantity).only_integer }
    it { should validate_numericality_of(:quantity).is_greater_than_or_equal_to(1) }
  end

  describe 'relationships' do
    it { should belong_to :order }
    it { should belong_to :item }
  end

  describe 'class methods' do
    it '.last_years_sales_by_month' do
      create(:order_item, updated_at: 1.months.ago, price: 100_000_000, quantity: 2)
      create(:fulfilled_order_item, updated_at: 1.months.ago, price: 1_000, quantity: 2)
      create(:fulfilled_order_item, updated_at: 2.months.ago, price: 1_000, quantity: 4)
      create(:fulfilled_order_item, updated_at: 3.months.ago, price: 1_000, quantity: 6)
      create(:fulfilled_order_item, updated_at: 4.months.ago, price: 1_000, quantity: 4)
      create(:fulfilled_order_item, updated_at: 4.months.ago, price: 1_000, quantity: 4)
      create(:fulfilled_order_item, updated_at: 6.months.ago, price: 100, quantity: 10)
      create(:fulfilled_order_item, updated_at: 8.months.ago, price: 100, quantity: 9)
      create(:fulfilled_order_item, updated_at: 10.months.ago, price: 100, quantity: 8)
      create(:fulfilled_order_item, updated_at: 11.months.ago, price: 100, quantity: 7)
      create(:fulfilled_order_item, updated_at: 12.months.ago, price: 100, quantity: 6)
      create(:fulfilled_order_item, updated_at: 13.months.ago, price: 100, quantity: 5)

      actual = OrderItem.last_years_sales_by_month
      expect(actual.last.revenue).to eq(2_000)
      expect(actual[-2].revenue).to eq(4_000)
      expect(actual[-4].revenue).to eq(8_000)
      expect(actual.first.revenue).to eq(600)
    end
  end

  describe 'instance methods' do
    it '.subtotal' do
      oi = create(:order_item, quantity: 5, price: 3)

      expect(oi.subtotal).to eq(15)
    end
  end
end
