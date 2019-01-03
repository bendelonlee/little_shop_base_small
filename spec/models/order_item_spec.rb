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
  end

  describe 'instance methods' do
    it '.undiscounted_subtotal' do
      oi = create(:order_item, quantity: 5, price: 3)
      expect(oi.subtotal).to eq(15)
    end
    describe 'subtotal' do
      scenario 'discount_type: percent' do
        merchant = create(:merchant)
        item = create(:item, user: merchant, price: 3)
        discount = create(:discount, user: merchant, min_amount: 10, discount_type: 'percent', value_off: 10)
        oi = create(:order_item, quantity: 10, price: 3, item: item)
        expect(oi.subtotal).to eq(27)
      end
      scenario 'discount_type: dollar amount' do
        merchant = create(:merchant)
        item = create(:item, user: merchant, price: 3)
        discount = create(:discount, user: merchant, min_amount: 30, discount_type: 'dollar', value_off: 10)
        oi = create(:order_item, quantity: 10, price: 3, item: item)
        expect(oi.subtotal).to eq(20)
      end
    end
    describe '.applicable_discount' do
      describe 'when none apply' do
        scenario 'because there are none' do
          oi = create(:order_item, quantity: 10, price: 3)
          expect(oi.applicable_discount).to eq(nil)
        end
        scenario 'because the quantity is too low' do
          oi = create(:order_item, quantity: 10, price: 3)
          merchant = oi.item.user
          discount = create(:discount, user: merchant, min_amount: 11, discount_type: 'percent', value_off: 10)

          expect(oi.applicable_discount).to eq(nil)
        end
      end
      describe 'when one might apply' do
        scenario 'with percent' do
          oi = create(:order_item, quantity: 10, price: 3)
          merchant = oi.item.user

          discount = create(:discount, user: merchant, min_amount: 10, discount_type: 'percent', value_off: 10)
          other_discount = create(:discount, min_amount: 5, discount_type: 'percent', value_off: 20)
          expect(oi.applicable_discount).to eq(discount)
        end
        scenario 'with dollar amount' do
          oi = create(:order_item, quantity: 10, price: 3)
          merchant = oi.item.user

          discount = create(:discount, user: merchant, min_amount: 30, discount_type: 'dollar', value_off: 10)
          other_discount = create(:discount, min_amount: 5, discount_type: 'percent', value_off: 20)
          expect(oi.applicable_discount).to eq(discount)
        end
      end
      describe 'when the largest value off should apply' do
        scenario 'with percent' do
          oi = create(:order_item, quantity: 20, price: 3)
          merchant = oi.item.user

          lower_discount = create(:discount, user: merchant, min_amount: 10, discount_type: 'percent', value_off: 10)
          higher_discount = create(:discount, user: merchant, min_amount: 20, discount_type: 'percent', value_off: 20)
          other_discount = create(:discount, min_amount: 5, discount_type: 'percent', value_off: 20)
          expect(oi.applicable_discount).to eq(higher_discount)
        end
        scenario 'with dollar amount' do
          oi = create(:order_item, quantity: 7, price: 3)
          merchant = oi.item.user

          lower_discount = create(:discount, user: merchant, min_amount: 10, discount_type: 'dollar', value_off: 2)
          higher_discount = create(:discount, user: merchant, min_amount: 20, discount_type: 'dollar', value_off: 3)
          other_discount = create(:discount, min_amount: 5, discount_type: 'dollar', value_off: 20)
          expect(oi.applicable_discount).to eq(higher_discount)
        end
      end
    end
    describe '.set_amount_discounted' do
      scenario 'with dollar amount' do
        merchant = create(:merchant)
        item = create(:item, user: merchant)

        lower_discount = create(:discount, user: merchant, min_amount: 10, discount_type: 'dollar', value_off: 2)
        higher_discount = create(:discount, user: merchant, min_amount: 20, discount_type: 'dollar', value_off: 3)
        other_discount = create(:discount, min_amount: 5, discount_type: 'dollar', value_off: 20)

        oi = create(:order_item, quantity: 7, price: 3, item: item)

        expect(oi.amount_discounted).to eq(3)
      end
      scenario 'with percent' do
        merchant = create(:merchant)
        item = create(:item, user: merchant)

        lower_discount = create(:discount, user: merchant, min_amount: 10, discount_type: 'percent', value_off: 5)
        higher_discount = create(:discount, user: merchant, min_amount: 20, discount_type: 'percent', value_off: 20)
        other_discount = create(:discount, min_amount: 5, discount_type: 'percent', value_off: 20)

        oi = create(:order_item, quantity: 19, price: 4, item: item)

        expect(oi.amount_discounted).to eq(3.80)
      end
    end
  end
end
