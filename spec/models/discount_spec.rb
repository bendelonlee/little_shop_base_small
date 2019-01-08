require "rails_helper"
describe Discount do
  it { should validate_presence_of :value_off }
  it { should validate_presence_of :discount_type }
  it { should validate_presence_of :min_amount }
  it { should belong_to :user }

  describe 'instance_methods' do
    it '.quantity_distribution' do
      @merchant = create(:merchant)
      @item = create(:item, user: @merchant)
      @oi_1 = create(:fulfilled_order_item, item: @item, quantity: 100)
      @oi_2 = create(:fulfilled_order_item, item: @item, quantity: 1)
    end
  end
end
