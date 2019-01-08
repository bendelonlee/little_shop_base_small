require "rails_helper"
describe Discount do
  describe 'validations' do
    it { should validate_presence_of :value_off }
    it { should validate_presence_of :discount_type }
    it { should validate_presence_of :min_amount }
    it { should belong_to :user }

    it 'should validate the uniqueness of a value off to a merchant' do
      merchant = create(:merchant)
      create(:discount, value_off: 12, user: merchant)
      discount = Discount.create(value_off: 12, user: merchant)
      expect(discount.errors[:value_off]).to include("You already have a discount with that value off")
    end

    it 'should validate the uniqueness of a minimum amount to a merchant' do
      merchant = create(:merchant)
      create(:discount, min_amount: 12, user: merchant)
      discount = Discount.create(min_amount: 12, user: merchant)
      expect(discount.errors[:min_amount]).to include("You already have a discount with that minimum amount")
    end

    it 'should validate a discount value off is less than 100 if the type is percentage' do
      discount = Discount.create(value_off: 100, discount_type: "percent")
      expect(discount.errors[:value_off]).to include("Discount percentage cannot be greater than 99")
      discount = Discount.create(value_off: 99, discount_type: "percent")
      expect(discount.errors[:value_off]).to_not include("Discount percentage cannot be greater than 99")
    end

    it 'should validate a discount dollars off is less than the minimum amount' do
      discount = Discount.create(value_off: 2, min_amount: 1, discount_type: "dollar")
      expect(discount.errors[:min_amount]).to include("Dollars off must be less than the minimum amount")
    end

  end

end
