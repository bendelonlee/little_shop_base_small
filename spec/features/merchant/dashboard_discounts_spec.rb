require "rails_helper"

include ActionView::Helpers::NumberHelper

RSpec.describe 'Merchant discount Page' do
  describe 'should show discount information' do
    before(:each) do
      @merchant = create(:merchant)
      @merchant_2 = create(:merchant)
      @discount_1 = create(:discount, user: @merchant, discount_type: "percent")
      @discount_2 = create(:discount, user: @merchant, discount_type: "dollar")
      @discount_3 = create(:discount, user: @merchant_2, discount_type: "dollar")
    end
    scenario 'as a merchant' do
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@merchant)
      visit dashboard_discounts_path
    end
    after(:each) do
      expect(page).to have_content("#{@discount_1.value_off}% off orders of #{@discount_1.min_amount} items or more.")
      expect(page).to have_content("$#{@discount_2.value_off} off orders of $#{@discount_2.min_amount} or more.")
      expect(page).to_not have_content("$#{@discount_3.value_off} off orders of $#{@discount_3.min_amount} or more.")
    end
  end
  it 'I can add add a percent discount' do
    merchant = create(:merchant)
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(merchant)

    visit dashboard_discounts_path
    click_link "Add A Discount"
    expect(current_path).to eq(new_dashboard_discount_path)

    value_off = "10"
    min_amount = "10"

    fill_in :discount_value_off, with: value_off
    fill_in :discount_min_amount, with: min_amount
    find('input[value="percent"]', visible: false).click
    click_on "Create Discount"
    expect(current_path).to eq(dashboard_discounts_path)
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(merchant.reload)
    visit(dashboard_discounts_path)
    within "#discount-#{Discount.last.id}" do
      expect(page).to have_content("#{value_off}% off orders of #{min_amount} items or more.")
    end

    click_link "Add A Discount"

    fill_in :discount_value_off, with: value_off
    fill_in :discount_min_amount, with: min_amount
    find('input[value="dollar"]', visible: false).click

    click_on "Create Discount"

    expect(current_path).to eq(dashboard_discounts_path)
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(merchant.reload)
    visit(dashboard_discounts_path)

    within "#discount-#{Discount.last.id}" do
      expect(page).to have_content("$#{value_off} off orders of $#{min_amount} or more.")
    end
  end
  it '' do

  end
end
