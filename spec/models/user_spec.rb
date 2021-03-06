require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    it { should validate_presence_of :email }
    it { should validate_uniqueness_of :email }
    it { should validate_presence_of :name }
    it { should validate_presence_of :address }
    it { should validate_presence_of :city }
    it { should validate_presence_of :state }
    it { should validate_presence_of :zip }
  end

  describe 'relationships' do
    it { should have_many :items }
    it { should have_many :orders }
    it { should have_many :discounts }
    it { should have_many(:order_items).through(:orders) }
  end

  describe 'class methods' do
    describe 'merchant stats' do
      before :each do
        @user_1 = create(:user, city: 'Denver', state: 'CO')
        @user_2 = create(:user, city: 'NYC', state: 'NY')
        @user_3 = create(:user, city: 'Seattle', state: 'WA')
        @user_4 = create(:user, city: 'Seattle', state: 'FL')

        @merchant_1, @merchant_2, @merchant_3 = create_list(:merchant, 3)
        @item_1 = create(:item, user: @merchant_1)
        @item_2 = create(:item, user: @merchant_2)
        @item_3 = create(:item, user: @merchant_3)

        @order_1 = create(:completed_order, user: @user_1)
        @oi_1 = create(:fulfilled_order_item, item: @item_1, order: @order_1, quantity: 100, price: 100, created_at: 10.minutes.ago, updated_at: 9.minute.ago)

        @order_2 = create(:completed_order, user: @user_2)
        @oi_2 = create(:fulfilled_order_item, item: @item_2, order: @order_2, quantity: 300, price: 300, created_at: 2.days.ago, updated_at: 1.minute.ago)

        @order_3 = create(:completed_order, user: @user_3)
        @oi_3 = create(:fulfilled_order_item, item: @item_3, order: @order_3, quantity: 200, price: 200, created_at: 10.minutes.ago, updated_at: 5.minute.ago)

        @order_4 = create(:completed_order, user: @user_4)
        @oi_4 = create(:fulfilled_order_item, item: @item_3, order: @order_4, quantity: 201, price: 200, created_at: 10.minutes.ago, updated_at: 5.minute.ago)
      end
      it '.top_3_revenue_merchants' do
        expect(User.top_3_revenue_merchants[0]).to eq(@merchant_2)
        expect(User.top_3_revenue_merchants[0].revenue.to_f).to eq(90000.00)
        expect(User.top_3_revenue_merchants[1]).to eq(@merchant_3)
        expect(User.top_3_revenue_merchants[1].revenue.to_f).to eq(80200.00)
        expect(User.top_3_revenue_merchants[2]).to eq(@merchant_1)
        expect(User.top_3_revenue_merchants[2].revenue.to_f).to eq(10000.00)
      end
      it '.merchant_fulfillment_times' do
        expect(User.merchant_fulfillment_times(:asc, 1)).to eq([@merchant_1])
        expect(User.merchant_fulfillment_times(:desc, 2)).to eq([@merchant_2, @merchant_3])
      end
      it '.top_3_fulfilling_merchants' do
        expect(User.top_3_fulfilling_merchants[0]).to eq(@merchant_1)
        aft = User.top_3_fulfilling_merchants[0].avg_fulfillment_time
        expect(aft[0..7]).to eq('00:01:00')
        expect(User.top_3_fulfilling_merchants[1]).to eq(@merchant_3)
        aft = User.top_3_fulfilling_merchants[1].avg_fulfillment_time
        expect(aft[0..7]).to eq('00:05:00')
        expect(User.top_3_fulfilling_merchants[2]).to eq(@merchant_2)
        aft = User.top_3_fulfilling_merchants[2].avg_fulfillment_time
        expect(aft[0..13]).to eq('1 day 23:59:00')
      end
      it '.bottom_3_fulfilling_merchants' do
        expect(User.bottom_3_fulfilling_merchants[0]).to eq(@merchant_2)
        aft = User.bottom_3_fulfilling_merchants[0].avg_fulfillment_time
        expect(aft[0..13]).to eq('1 day 23:59:00')
        expect(User.bottom_3_fulfilling_merchants[1]).to eq(@merchant_3)
        aft = User.bottom_3_fulfilling_merchants[1].avg_fulfillment_time
        expect(aft[0..7]).to eq('00:05:00')
        expect(User.bottom_3_fulfilling_merchants[2]).to eq(@merchant_1)
        aft = User.bottom_3_fulfilling_merchants[2].avg_fulfillment_time
        expect(aft[0..7]).to eq('00:01:00')
      end
    end
  end

  describe 'instance methods' do
    it '.my_pending_orders' do
      merchants = create_list(:merchant, 2)
      item_1 = create(:item, user: merchants[0])
      item_2 = create(:item, user: merchants[1])
      orders = create_list(:order, 3)
      create(:order_item, order: orders[0], item: item_1, price: 1, quantity: 1)
      create(:order_item, order: orders[1], item: item_2, price: 1, quantity: 1)
      create(:order_item, order: orders[2], item: item_1, price: 1, quantity: 1)

      expect(merchants[0].my_pending_orders).to eq([orders[0], orders[2]])
      expect(merchants[1].my_pending_orders).to eq([orders[1]])
    end

    it '.inventory_check' do
      admin = create(:admin)
      user = create(:user)
      merchant = create(:merchant)
      item = create(:item, user: merchant, inventory: 100)

      expect(admin.inventory_check(item.id)).to eq(nil)
      expect(user.inventory_check(item.id)).to eq(nil)
      expect(merchant.inventory_check(item.id)).to eq(item.inventory)
    end

    describe 'merchant stats methods' do
      before :each do
        @user_1 = create(:user, city: 'Springfield', state: 'MO')
        @user_2 = create(:user, city: 'Springfield', state: 'CO')
        @user_3 = create(:user, city: 'Las Vegas', state: 'NV')
        @user_4 = create(:user, city: 'Denver', state: 'CO')

        @merchant = create(:merchant)
        @item_1, @item_2, @item_3, @item_4 = create_list(:item, 4, user: @merchant, inventory: 20)

        @order_1 = create(:completed_order, user: @user_1)
        @oi_1a = create(:fulfilled_order_item, order: @order_1, item: @item_1, quantity: 2, price: 100)

        @order_2 = create(:completed_order, user: @user_1)
        @oi_1b = create(:fulfilled_order_item, order: @order_2, item: @item_1, quantity: 1, price: 80)

        @order_3 = create(:completed_order, user: @user_2)
        @oi_2 = create(:fulfilled_order_item, order: @order_3, item: @item_2, quantity: 5, price: 60)

        @order_4 = create(:completed_order, user: @user_3)
        @oi_3 = create(:fulfilled_order_item, order: @order_4, item: @item_3, quantity: 3, price: 40)

        @order_5 = create(:completed_order, user: @user_4)
        @oi_4 = create(:fulfilled_order_item, order: @order_5, item: @item_4, quantity: 4, price: 20)
      end
      it '.top_items_by_quantity' do
        expect(@merchant.top_items_by_quantity(5)).to eq([@item_2, @item_4, @item_1, @item_3])
      end
      it '.quantity_sold_percentage' do
        expect(@merchant.quantity_sold_percentage[:sold]).to eq(15)
        expect(@merchant.quantity_sold_percentage[:total]).to eq(95)
        expect(@merchant.quantity_sold_percentage[:percentage]).to eq(15.79)
      end
      it '.top_3_states' do
        expect(@merchant.top_3_states.first.state).to eq('CO')
        expect(@merchant.top_3_states.first.quantity_shipped).to eq(9)
        expect(@merchant.top_3_states.second.state).to eq('MO')
        expect(@merchant.top_3_states.second.quantity_shipped).to eq(3)
        expect(@merchant.top_3_states.third.state).to eq('NV')
        expect(@merchant.top_3_states.third.quantity_shipped).to eq(3)
      end
      it '.top_3_cities' do
        expect(@merchant.top_3_cities.first.city).to eq('Springfield')
        expect(@merchant.top_3_cities.first.state).to eq('CO')
        expect(@merchant.top_3_cities.second.city).to eq('Denver')
        expect(@merchant.top_3_cities.second.state).to eq('CO')
        expect(@merchant.top_3_cities.third.city).to eq('Springfield')
        expect(@merchant.top_3_cities.third.state).to eq('MO')
      end
      it '.most_ordering_user' do
        expect(@merchant.most_ordering_user).to eq(@user_1)
        expect(@merchant.most_ordering_user.order_count).to eq(2)
      end
      it '.most_items_user' do
        expect(@merchant.most_items_user).to eq(@user_2)
        expect(@merchant.most_items_user.item_count).to eq(5)
      end
      it '.top_3_revenue_users' do
        expect(@merchant.top_3_revenue_users[0]).to eq(@user_2)
        expect(@merchant.top_3_revenue_users[0].revenue).to eq(300)
        expect(@merchant.top_3_revenue_users[1]).to eq(@user_1)
        expect(@merchant.top_3_revenue_users[1].revenue).to eq(280)
        expect(@merchant.top_3_revenue_users[2]).to eq(@user_3)
        expect(@merchant.top_3_revenue_users[2].revenue).to eq(120)
      end
      it '.merchants_by_revenue' do
        @merchant_2, @merchant_no_fulfilled = create_list(:merchant, 2)

        @item_5 = create(:item, inventory: 500, price: 1000, user: @merchant_2)
        @item_6 = create(:item, inventory: 500, price: 1000, user: @merchant_no_fulfilled)

        @order_6 = create(:completed_order, user: @user_1)
        @oi_6 = create(:fulfilled_order_item, order: @order_6, item: @item_5, quantity: 20, price: 1000, updated_at: 2.months.ago)

        @order_7 = create(:cancelled_order, user: @user_1)
        @oi_7 = create(:order_item, order: @order_7, item: @item_6, quantity: 20, price: 1000, updated_at: 2.months.ago)

        @order_8 = create(:order, user: @user_1)
        @oi_8 = create(:order_item, order: @order_8, item: @item_6, quantity: 20, price: 1000, updated_at: 2.months.ago)

        actual = User.merchants_by_revenue
        expect(actual).to eq([@merchant_2, @merchant])
        expect(actual.first.revenue).to eq(20_000)
      end
    end
    it '.twelve_months_revenue' do
      merchant = create(:merchant)
      item = create(:item, user: merchant)
      create(:order_item, updated_at: 1.months.ago, price: 100_000_000, quantity: 2, item: item)
      create(:fulfilled_order_item, updated_at: 1.months.ago, price: 100_000_000, quantity: 2)
      create(:fulfilled_order_item, updated_at: 1.months.ago, price: 1_000, quantity: 2, item: item)
      create(:fulfilled_order_item, updated_at: 2.months.ago, price: 1_000, quantity: 4, item: item)
      create(:fulfilled_order_item, updated_at: 3.months.ago, price: 1_000, quantity: 6, item: item)
      create(:fulfilled_order_item, updated_at: 4.months.ago, price: 1_000, quantity: 4, item: item)
      create(:fulfilled_order_item, updated_at: 4.months.ago, price: 1_000, quantity: 4, item: item)
      create(:fulfilled_order_item, updated_at: 6.months.ago, price: 100, quantity: 10, item: item)
      create(:fulfilled_order_item, updated_at: 8.months.ago, price: 100, quantity: 9, item: item)
      create(:fulfilled_order_item, updated_at: 10.months.ago, price: 100, quantity: 8, item: item)
      create(:fulfilled_order_item, updated_at: 11.months.ago, price: 100, quantity: 7, item: item)
      create(:fulfilled_order_item, updated_at: 12.months.ago, price: 100, quantity: 6, item: item)
      create(:fulfilled_order_item, updated_at: 13.months.ago, price: 100, quantity: 5, item: item)

      actual = merchant.twelve_months_revenue
      expect(actual.last.revenue).to eq(2_000)
      expect(actual[-2].revenue).to eq(4_000)
      expect(actual[-4].revenue).to eq(8_000)
      expect(actual.first.revenue).to eq(600)
    end
    it '.past_3_months_sales' do
      merchant = create(:merchant)
      item = create(:item, user: merchant)
      create(:order_item, updated_at: Date.today.change(day: 1) - 1.days, price: 100_000_000, quantity: 2, item: item)
      create(:fulfilled_order_item, updated_at: Date.today.change(day: 1) - 1.days, price: 100_000_000, quantity: 2)
      create(:fulfilled_order_item, updated_at: Date.today.change(day: 1) - 1.days, price: 1_000, quantity: 2, item: item)
      create(:fulfilled_order_item, updated_at: Date.today.change(day: 1) - 2.days, price: 1_000, quantity: 4, item: item)
      create(:fulfilled_order_item, updated_at: Date.today.change(day: 1) - 3.days, price: 1_000, quantity: 6, item: item)
      create(:fulfilled_order_item, updated_at: Date.today.change(day: 1) - 4.days, price: 1_000, quantity: 4, item: item)
      create(:fulfilled_order_item, updated_at: Date.today.change(day: 1) - 4.days, price: 1_000, quantity: 4, item: item)
      create(:fulfilled_order_item, updated_at: Date.today.change(day: 1) - 6.days, price: 100, quantity: 10, item: item)
      create(:fulfilled_order_item, updated_at: Date.today.change(day: 1) - 8.days, price: 100, quantity: 9, item: item)
      create(:fulfilled_order_item, updated_at: Date.today.change(day: 1) - 10.days, price: 100, quantity: 8, item: item)
      create(:fulfilled_order_item, updated_at: Date.today.change(day: 1) - 11.days, price: 100, quantity: 7, item: item)
      create(:fulfilled_order_item, updated_at: Date.today.change(day: 1) - 88.days, price: 100, quantity: 6, item: item)
      create(:fulfilled_order_item, updated_at: Date.today.change(day: 1) - 200.days, price: 100, quantity: 5, item: item)

      actual = merchant.past_3_months_sales
      expect(actual.length.between?(89,92)).to eq(true)
      expect(actual.last['revenue']).to eq(2_000)
      expect(actual[-2]['revenue']).to eq(4_000)
      expect(actual[-4]['revenue']).to eq(8_000)
      expect(actual.first['revenue']).to_not eq(500)
    end

    it '.oi_quantity_distribution' do
      @merchant = create(:merchant)
      @item = create(:item, user: @merchant)
      create(:fulfilled_order_item, item: @item, quantity: 3)
      create(:fulfilled_order_item, item: @item, quantity: 2)
      create(:fulfilled_order_item, item: @item, quantity: 1)
      create(:fulfilled_order_item, item: @item, quantity: 75)
      create(:fulfilled_order_item, item: @item, quantity: 100)
      create(:fulfilled_order_item, quantity: 100)
      actual = @merchant.oi_quantity_distribution[0]

      expect(actual.lowest).to eq(1)
      expect(actual.low_q).to eq(2)
      expect(actual.median).to eq(3)
      expect(actual.high_q).to eq(75)

      expect(actual.highest).to eq(100)
    end

    describe 'before and after discount' do
      before(:each) do
        @merchant = create(:merchant)
        @item = create(:item, user: @merchant)
        @discount = create(:discount, user: @merchant, created_at: 2.days.ago)
        create(:fulfilled_order_item, item: @item, quantity: 3, updated_at: 3.days.ago)
        create(:fulfilled_order_item, item: @item, quantity: 2, updated_at: 3.days.ago)
        create(:fulfilled_order_item, item: @item, quantity: 1, updated_at: 3.days.ago)
        create(:fulfilled_order_item, item: @item, quantity: 75, updated_at: 3.days.ago)
        create(:fulfilled_order_item, item: @item, quantity: 100, updated_at: 3.days.ago)
        create(:fulfilled_order_item, item: @item, quantity: 100, updated_at: 1.days.ago)
        create(:fulfilled_order_item, quantity: 100, updated_at: 3.days.ago)
      end

      it 'oi_quant_d_before_discount' do
        actual = @merchant.oi_quant_d_before_discount(@discount)[0]
        expect(actual.lowest).to eq(1)
        expect(actual.low_q).to eq(2)
        expect(actual.median).to eq(3)
        expect(actual.high_q).to eq(75)
        expect(actual.highest).to eq(100)
      end

      it 'oi_quant_d_after_discount' do
        actual = @merchant.oi_quant_d_after_discount(@discount)[0]
        expect(actual.lowest).to eq(100)
        expect(actual.low_q).to eq(100)
        expect(actual.median).to eq(100)
        expect(actual.high_q).to eq(100)
        expect(actual.highest).to eq(100)
      end
    end
  end
end
