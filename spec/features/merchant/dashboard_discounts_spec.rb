require "rails_helper"

include ActionView::Helpers::NumberHelper

RSpec.describe 'Merchant Discount Page' do
  context 'as a merchant'
    it 'I see my bulk discount information' do
      merchant = create(:merchant)
      discount_1 = create(:discount, user: merchant, discount_type: "percent")
      discount_2 = create(:discount, user: merchant, discount_type: "dollar")

      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(merchant)

      visit dashboard_discounts_path

      expect(page).to have_content("#{discount_1.value_off}% off orders of #{discount_1.min_amount} items or more.")
      expect(page).to have_content("$#{discount_2.value_off} off orders of $#{discount_2.min_amount} or more.")
    end
end
