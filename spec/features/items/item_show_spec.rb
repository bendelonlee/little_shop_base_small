require 'rails_helper'

include ActionView::Helpers::NumberHelper
include ApplicationHelper

RSpec.describe 'Item show page', type: :feature do
  before :each do
    @admin = create(:admin)
    @merchant = create(:merchant)
    @discount = create(:discount, user: @merchant, discount_type: 'dollar')
    @item = create(:item, user: @merchant)
    @item_2 = create(:item, user: @merchant, inventory: 0)
    @user = create(:user)
    @order = create(:completed_order, user: @user)
    create(:fulfilled_order_item, order: @order, item: @item, created_at: 4.days.ago, updated_at: 3.days.ago)
    create(:fulfilled_order_item, order: @order, item: @item, created_at: 1.hour.ago, updated_at: 30.minutes.ago)
  end
  it 'should hide Add To Cart button if inventory is 0' do
    visit item_path(@item_2)
    expect(page).to have_content('Merchant is out of stock, sorry')
    expect(page).to_not have_button('Add to Cart')
    visit item_path(@item)
  end
  describe 'should show details about a single item' do
    scenario 'as a visitor' do
      visit item_path(@item)
      expect(page).to have_button('Add to Cart')
    end
    scenario 'as a registered user' do
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@user)
      visit item_path(@item)
      expect(page).to have_button('Add to Cart')
    end
    scenario 'as a merchant' do
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@merchant)
      visit item_path(@item)
      expect(page).to_not have_button('Add to Cart')
    end
    scenario 'as an admin' do
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@admin)
      visit item_path(@item)
      expect(page).to_not have_button('Add to Cart')
    end
    after :each do
      within "#item-#{@item.id}" do
        expect(page).to have_content(@item.name)
        expect(page.find("#item-#{@item.id}-image")['src']).to have_content(@item.image)
        expect(page).to have_content("Sold by: #{@item.user.name}")
        expect(page).to have_content("Price: #{number_to_currency(@item.price)}")
        expect(page).to have_content("In stock: #{@item.inventory}")
        expect(page).to have_content("Average time to fulfill: 12 hours, 15 minutes")
        expect(page).to have_content(describe_discount(@discount))
      end
    end
  end
end
