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
  describe 'I can add add a discount' do
    before(:each) do
      @merchant = create(:merchant)
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@merchant)
      @value_off = "10"
      @min_amount = "10"
      visit dashboard_discounts_path
      click_link "Add A Discount"
      expect(current_path).to eq(new_dashboard_discount_path)
      fill_in :discount_value_off, with: @value_off
      fill_in :discount_min_amount, with: @min_amount
    end
    it "with percent discount type" do
      find('input[value="percent"]', visible: false).click
      @expected = "#{@value_off}% off orders of #{@min_amount} items or more."
    end
    it "with dollar discount type" do
      find('input[value="dollar"]', visible: false).click
      @expected = "$#{@value_off} off orders of $#{@min_amount} or more."
    end
    after(:each) do
      click_on "Create Discount"
      expect(current_path).to eq(dashboard_discounts_path)
      expect(page).to have_content("Discount ##{Discount.last.id} has been created.")
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@merchant.reload)
      visit(dashboard_discounts_path)
      within "#discount-#{Discount.last.id}" do
        expect(page).to have_content(@expected)
      end
    end
  end
  describe 'Adding a discount with bad information gives errors' do

  end
  describe 'I can edit a discount' do
    it 'with good info' do
      @merchant = create(:merchant)
      @discount = create(:discount, user: @merchant, discount_type: "percent")
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@merchant)
      @new_value_off = "101"
      @new_min_amount = "101"
      @new_discount_type = "dollar"
      visit dashboard_discounts_path
      within "#discount-#{@discount.id}" do
        click_on "Edit"
      end

      expect(current_path).to eq(edit_dashboard_discount_path(@discount))
      fill_in :discount_value_off, with: @new_value_off
      fill_in :discount_min_amount, with: @new_min_amount
      find("input[value=\"#{@new_discount_type}\"]", visible: false).click

      click_on "Update Discount"

      expect(current_path).to eq(dashboard_discounts_path)
      expect(page).to have_content("Discount ##{@discount.id} has been updated.")
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@merchant.reload)
      visit(dashboard_discounts_path)
      within "#discount-#{Discount.last.id}" do
        expect(page).to have_content("$#{@new_value_off} off orders of $#{@new_min_amount} or more.")
      end
    end
  end
  describe 'I can delete a discount' do
    scenario 'when it has never been ordered' do
      @merchant = create(:merchant)
      @discount = create(:discount, user: @merchant, discount_type: "percent")
      @discount_2 = create(:discount, user: @merchant, discount_type: "percent")
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@merchant)
      visit dashboard_discounts_path
      within "#discount-#{@discount.id}" do
        click_on "Delete"
      end
      expect(page).to have_content("Discount ##{@discount.id} has been deleted.")
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@merchant.reload)
      visit(dashboard_discounts_path)
      expect(page).to have_content("#{@discount_2.value_off}% off orders of #{@discount_2.min_amount} items or more.")
      expect(page).to_not have_content("#{@discount.value_off}% off orders of #{@discount.min_amount} items or more.")
    end
  end
end
