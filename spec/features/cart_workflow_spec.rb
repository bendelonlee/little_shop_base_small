require 'rails_helper'

include ActionView::Helpers::NumberHelper

RSpec.describe 'Cart workflow', type: :feature do
  before :each do
    @merchant = create(:merchant)
    @item = create(:item, user: @merchant)
  end

  describe 'shows an empty cart when no items are added' do
    scenario 'as a visitor' do
      visit cart_path
    end
    scenario 'as a registered user' do
      user = create(:user)
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)
      visit cart_path
    end
    after :each do
      expect(page).to have_content('Your cart is empty')
      expect(page).to_not have_button('Emtpy cart')
    end
  end

  describe 'allows visitors to add items to cart' do
    scenario 'as a visitor' do
      visit item_path(@item)
    end
    scenario 'as a registered user' do
      user = create(:user)
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)
      visit item_path(@item)
    end
    after :each do
      click_button "Add to Cart"
      expect(page).to have_content("You have 1 package of #{@item.name} in your cart")
      expect(page).to have_link("Cart: 1")
      expect(current_path).to eq(items_path)

      visit item_path(@item)
      click_button "Add to Cart"

      expect(page).to have_content("You have 2 packages of #{@item.name} in your cart")
      expect(page).to have_link("Cart: 2")
    end
  end

  describe 'shows an empty cart when no items are added' do
    before :each do
      @item_2 = create(:item, user: @merchant)
    end
    scenario 'as a visitor' do
      visit item_path(@item)
    end
    scenario 'as a registered user' do
      user = create(:user)
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)
      visit item_path(@item)
    end
    after :each do
      click_button "Add to Cart"
      visit item_path(@item_2)
      click_button "Add to Cart"
      visit item_path(@item_2)
      click_button "Add to Cart"

      visit cart_path

      expect(page).to_not have_content('Your cart is empty')
      expect(page).to have_button('Empty cart')

      within "#item-#{@item.id}" do
        expect(page).to have_content(@item.name)
        expect(page.find("#item-#{@item.id}-image")['src']).to have_content(@item.image)
        expect(page).to have_content("Merchant: #{@item.user.name}")
        expect(page).to have_content("Price: #{number_to_currency(@item.price)}")
        expect(page).to have_content("Quantity: 1")
        expect(page).to have_content("Subtotal: #{number_to_currency(@item.price*1)}")
      end
      within "#item-#{@item_2.id}" do
        expect(page).to have_content(@item_2.name)
        expect(page.find("#item-#{@item_2.id}-image")['src']).to have_content(@item_2.image)
        expect(page).to have_content("Merchant: #{@item_2.user.name}")
        expect(page).to have_content("Price: #{number_to_currency(@item_2.price)}")
        expect(page).to have_content("Quantity: 2")
        expect(page).to have_content("Subtotal: #{number_to_currency(@item_2.price*2)}")
      end
      expect(page).to have_content("Total: #{number_to_currency(@item.price + (@item_2.price*2)) }")
    end
  end

  describe 'users can empty their cart if it has items in it' do
    scenario 'as a visitor' do
      visit item_path(@item)
    end
    scenario 'as a registered user' do
      user = create(:user)
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)
      visit item_path(@item)
    end
    after :each do
      click_button "Add to Cart"
      visit cart_path

      expect(page).to_not have_content('Your cart is empty')
      click_button 'Empty cart'

      expect(current_path).to eq(cart_path)
      expect(page).to have_content('Your cart is empty')
      expect(page).to have_link('Cart: 0')
    end
  end

  describe 'users can increase or decrease cart quantities' do
    before :each do
      @item_2 = create(:item, user: @merchant, inventory: 3)
    end
    scenario 'as a visitor' do
      visit item_path(@item)
    end
    scenario 'as a registered user' do
      user = create(:user)
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)
      visit item_path(@item)
    end
    after :each do
      click_button "Add to Cart"
      visit cart_path

      within "#item-#{@item.id}" do
        click_button 'Remove all from cart'
      end
      expect(page).to have_content("You have removed all packages of #{@item.name} from your cart")
      expect(page).to have_content('Your cart is empty')
      expect(page).to have_link('Cart: 0')

      visit item_path(@item_2)
      click_button "Add to Cart"
      visit cart_path

      within "#item-#{@item_2.id}" do
        click_button 'Add more to cart'
      end
      within "#item-#{@item_2.id}" do
        click_button 'Add more to cart'
      end
      expect(page).to have_link('Cart: 3')

      within "#item-#{@item_2.id}" do
        expect(page).to_not have_button('Add more to cart')
      end

      within "#item-#{@item_2.id}" do
        click_button 'Remove one from cart'
      end
      within "#item-#{@item_2.id}" do
        click_button 'Remove one from cart'
      end
      expect(page).to have_content("You have removed 1 package of #{@item_2.name} from your cart, new quantity is 1")
      within "#item-#{@item_2.id}" do
        click_button 'Remove one from cart'
      end
      expect(page).to have_content('Your cart is empty')
      expect(page).to have_link('Cart: 0')
    end
  end

  describe 'users can checkout (or not) depending on role' do
    scenario 'as a visitor' do
      visit item_path(@item)
      click_button "Add to Cart"
      visit cart_path
      expect(page).to have_content('You must register or log in to check out')
    end
    describe 'as a registered user' do
      scenario 'base case' do
        @user = create(:user)
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@user)

        visit item_path(@item)
        click_button "Add to Cart"
        visit cart_path

        click_button 'Check out'

        expect(current_path).to eq(profile_path)
        expect(page).to have_content('You have successfully checked out!')

        visit profile_orders_path
        expect(page).to have_content("Order ID #{Order.last.id}")

      end
      scenario 'when discounts apply' do
        @item.update(inventory: 200)
        discount = create(:discount, user: @merchant, min_amount: 10, discount_type: 'percent', value_off: 10)
        @user = create(:user)
        not_expected_total = "30.00"
        expected_total = "27.00"
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@user)

        visit item_path(@item)

        click_button "Add to Cart"
        visit cart_path
        9.times do
          within "#item-#{@item.id}" do
            click_button 'Add more to cart'
          end
        end
        within "#item-#{@item.id}" do
          expect(page).to have_content("Orders of 10 items or more recieve 10% off")
          expect(page).to have_content("Discounted: - $3.00")
        end
        expect(page).to have_content("Total: $#{expected_total}")
        within "#item-#{@item.id}" do
          expect(page).to have_content("Subtotal: $#{expected_total}")
        end

        click_button 'Check out'

        expect(current_path).to eq(profile_path)
        expect(page).to have_content('You have successfully checked out!')

        visit profile_orders_path
        expect(page).to have_content("Order ID #{Order.last.id}")
        visit profile_order_path(Order.last)

        expect(page).to_not have_content("Total Cost: #{number_to_currency(not_expected_total)}")
        expect(page).to have_content("Total Cost: #{number_to_currency(expected_total)}")
      end
    end
  end

  context 'as a merchant' do
    it 'does not allow merchants to add items to a cart' do
      merchant = create(:merchant)
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(merchant)

      visit item_path(@item)

      expect(page).to_not have_button("Add to cart")
    end
  end

  context 'as an admin' do
    it 'does not allow admins to add items to a cart' do
      merchant = create(:merchant)
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(merchant)

      visit item_path(@item)

      expect(page).to_not have_button("Add to cart")
    end
  end
end
