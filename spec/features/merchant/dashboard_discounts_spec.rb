require "rails_helper"

include ActionView::Helpers::NumberHelper

RSpec.describe 'Merchant discount Page' do
  describe 'should show discount information and link to a show page' do
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
      @expected_show_path = dashboard_discount_path(@discount_1)
    end
    scenario 'as an admin' do
      @admin = create(:admin)
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@admin)
      visit admin_merchant_discounts_path(@merchant)
      @expected_show_path = admin_merchant_discount_path(@merchant, @discount_1)
    end
    after(:each) do
      within "#discount-#{@discount_1.id}" do
        expect(page).to have_content("#{@discount_1.value_off}% off orders of #{@discount_1.min_amount} items or more.")
        expect(page).to have_content("Discount ##{@discount_1.id}")
      end
      within "#discount-#{@discount_2.id}" do
        expect(page).to have_content("$#{@discount_2.value_off} off orders of $#{@discount_2.min_amount} or more.")
        expect(page).to have_content("Discount ##{@discount_2.id}")
      end
      expect(page).to_not have_content("$#{@discount_3.value_off} off orders of $#{@discount_3.min_amount} or more.")
      expect(page).to_not have_content("Discount ##{@discount_3.id}")

      click_on("Discount ##{@discount_1.id}")
      expect(current_path).to eq(@expected_show_path)
    end
  end

  describe 'I can add add a discount' do
    before(:each) do
      @merchant = create(:merchant)
      @admin = create(:admin)
      @value_off = "9"
      @min_amount = "10"
    end
    scenario 'as a merchant with percent discount type' do
      @sign_in = Proc.new do
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@merchant.reload)
      end
      @index_path = dashboard_discounts_path
      @new_path = new_dashboard_discount_path
      @discount_type = "percent"
      @expected = "#{@value_off}% off orders of #{@min_amount} items or more."
    end
    scenario 'as an admin with dollar discount type' do
      @sign_in = Proc.new do
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@admin.reload)
        @index_path = admin_merchant_discounts_path(@merchant.reload)
      end
      @discount_type = "percent"
      @index_path = admin_merchant_discounts_path(@merchant)
      @new_path = new_admin_merchant_discount_path(@merchant)
      @discount_type = "dollar"
      @expected = "$#{@value_off} off orders of $#{@min_amount} or more."
    end
    after(:each) do
      @sign_in.call
      visit @index_path
      click_link "Add A Discount"
      expect(current_path).to eq(@new_path)
      fill_in :discount_value_off, with: @value_off
      fill_in :discount_min_amount, with: @min_amount
      find("input[value=\"#{@discount_type}\"]", visible: false).click

      click_on "Create Discount"
      expect(current_path).to eq(@index_path)
      expect(page).to have_content("Discount ##{Discount.last.id} has been created.")
      @sign_in.call
      visit(@index_path)
      within "#discount-#{Discount.last.id}" do
        expect(page).to have_content(@expected)
      end
    end
  end

  ['merchant', 'admin'].each do |whosviewing|
    describe "as #{whosviewing}," do
      before(:each) do
        @merchant = create(:merchant)
        @admin = create(:admin)
      end
      case whosviewing
      when 'admin'
        let(:sign_in) do
          Proc.new do
            allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@admin.reload)
            @merchant.reload
          end
        end
        let(:index_path) { admin_merchant_discounts_path(@merchant) }
        let(:form_paths) {
          { edit: Proc.new { edit_admin_merchant_discount_path(@merchant, @discount) },
          new: Proc.new { new_admin_merchant_discount_path(@merchant) } }
        }
      when 'merchant'
        let(:sign_in) do
          Proc.new do
            allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@merchant.reload)
          end
        end
        let(:index_path) { dashboard_discounts_path }
        let(:form_paths) {
          { edit: Proc.new { edit_dashboard_discount_path(@discount) },
          new: Proc.new { new_dashboard_discount_path } }
        }
      end
      describe 'entering bad data into discount form gives errors' do
        ['adding', 'editing'].each do |whatimdoing|
          describe "when #{whatimdoing} a discount" do
            before(:each) do
              case whatimdoing
              when 'adding'
                @submit = "Create Discount"
                @am_adding = true
                @click_form_link = Proc.new { click_on "Add A Discount" }
                @form_path = form_paths[:new].call
              when 'editing'
                @discount = create(:discount, user: @merchant)
                @submit = "Update Discount"
                @form_path = form_paths[:edit].call
                @click_form_link = Proc.new do
                  within "#discount-#{@discount.id}" do
                    click_on "Edit"
                  end
                end
              end
              sign_in.call
            end
            scenario "discount type can't be blank, value off can't be negative, min amount must be more than 2" do
              visit index_path
              @click_form_link.call
              expect(current_path).to eq(@form_path)
              fill_in :discount_value_off, with: "-1"
              fill_in :discount_min_amount, with: "1"
              click_on @submit
              expect(page).to have_content("Discount type can't be blank") if @am_adding
              expect(page).to_not have_content("Discount type can't be blank") unless @am_adding
              expect(page).to have_content("Value off must be greater than or equal to 0")
              expect(page).to have_content("Min amount must be greater than or equal to 2")
              expect(Discount.count).to eq(0) if @am_adding
              expect(Discount.count).to eq(1) unless @am_adding
            end
            scenario 'discount value off must be integer, min amount never blank' do
              visit index_path
              @click_form_link.call

              fill_in :discount_value_off, with: "0.1"
              fill_in :discount_min_amount, with: ""
              click_on @submit

              expect(page).to have_content("Min amount can't be blank")
              expect(page).to have_content("Min amount is not a number")
              expect(page).to have_content("Value off must be an integer")

              expect(Discount.count).to eq(0) if @am_adding
            end
            scenario "value off never over one hundred when percent" do
              visit index_path
              @click_form_link.call

              fill_in :discount_value_off, with: "100"
              fill_in :discount_min_amount, with: "10"
              find("input[value=\"#{"percent"}\"]", visible: false).click if @am_adding

              click_on @submit

              expect(page).to have_content("Discount percentage cannot be greater than 99")

              expect(Discount.count).to eq(0) if @am_adding
            end
            scenario "dollars off can't be greater than min amount" do
              visit index_path
              @click_form_link.call

              fill_in :discount_value_off, with: "99"
              fill_in :discount_min_amount, with: "10"

              click_on @submit

              expect(page).to_not have_content("Dollars off cannot exceed minimum amount")

              expect(Discount.count).to eq(0) if @am_adding
              expect(Discount.count).to eq(1) unless @am_adding
            end
            scenario "dollars off must be less than the minimum amount" do

              @discount.update(discount_type: "dollar") unless @am_adding
              sign_in.call
              visit index_path
              @click_form_link.call
              fill_in :discount_value_off, with: "3"
              fill_in :discount_min_amount, with: "2"
              find("input[value='dollar']", visible: false).click if @am_adding

              click_on @submit

              expect(page).to have_content("Dollars off must be less than the minimum amount")
              expect(Discount.count).to eq(0) if @am_adding
              expect(Discount.count).to eq(1) unless @am_adding
            end
            scenario 'a value off and min amount must be uniqe to the merchant and a discount can be saved after errors reported/rerender' do
              same_value_off = 11
              same_min_amount = 21
              new_value_off = 70
              new_min_amount = 400

              create(:discount, value_off: same_value_off, min_amount: same_min_amount, user: @merchant)
              sign_in.call
              visit index_path
              @click_form_link.call
              fill_in :discount_value_off, with: same_value_off
              fill_in :discount_min_amount, with: same_min_amount

              click_on @submit

              expect(page).to have_content("You already have a discount with that minimum amount")
              expect(page).to have_content("You already have a discount with that value off")

              fill_in :discount_value_off, with: new_value_off
              fill_in :discount_min_amount, with: new_min_amount

              click_on @submit
              sign_in.call
              visit index_path
              within "#discount-#{ Discount.find_by(updated_at: Discount.maximum(:updated_at)).id }" do
                expect(page).to have_content("#{new_value_off}% off orders of #{new_min_amount} items or more.")
              end
            end

          end
        end
        it "When a discount would never be used, a warning appears" do
          discount_1 = create(:discount, user: @merchant, min_amount: 100, value_off: 4, discount_type: "dollar")
          discount_2 = create(:discount, user: @merchant, min_amount: 10, value_off: 5, discount_type: "dollar")
          sign_in.call
          visit index_path
          within "#discount-#{discount_1.id}" do
            expect(page).to have_content("WARNING: Because only the discount with the highest value off can apply to an order, this discount will never be used.")
          end
          within "#discount-#{discount_2.id}" do
            expect(page).to_not have_content("WARNING: Because only the discount with the highest value off can apply to an order, this discount will never be used.")
          end

        end
        describe "when a discount isn't the first, there is no choice for discount type" do
          before(:each) do
            create(:discount, user: @merchant, discount_type: "percent")
            @discount = create(:discount, user: @merchant, discount_type: "percent")

            sign_in.call
            @new_value_off = "98"
            @new_min_amount = "99"
            @new_discount_type = "dollar"
            visit index_path
          end
          scenario "when adding a discount" do
            click_link "Add A Discount"
            @submit = "Create Discount"
          end
          scenario "when editing a discount" do
            within "#discount-#{@discount.id}" do
              click_link "Edit"
            end
            @submit = "Update Discount"
          end
          after(:each) do
            fill_in :discount_value_off, with: @new_value_off
            fill_in :discount_min_amount, with: @new_min_amount
            expect(page).to_not have_css("#discount-type-radio")
            expect(page).to have_content("Your discount type is: percent. (To change your discount type, delete or disable all active discounts)")

            click_on @submit
            sign_in.call
            visit index_path
            within "#discount-#{Discount.last.id}" do
              expect(page).to have_content("#{@new_value_off}% off orders of #{@new_min_amount} items or more.")
            end
          end
        end
      end
    end

    describe 'I can edit a discount with good info' do
      before(:each) do
        @merchant = create(:merchant)
        @admin = create(:admin)
        @discount = create(:discount, user: @merchant, discount_type: "percent")
      end
      scenario 'as an admin' do
        @sign_in = Proc.new do
          allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@admin.reload)
        end
        @index_path = admin_merchant_discounts_path(@merchant)
        @edit_path = edit_admin_merchant_discount_path(@merchant, @discount)
      end
      scenario 'as a merchant' do
        @sign_in = Proc.new do
          allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@merchant.reload)
        end
        @index_path = dashboard_discounts_path
        @edit_path = edit_dashboard_discount_path(@discount)
      end
      after(:each) do
        @new_value_off = 98
        @new_min_amount = 99
        @new_discount_type = "dollar"
        @sign_in.call

        visit @index_path
        within "#discount-#{@discount.id}" do
          click_on "Edit"
        end

        expect(current_path).to eq(@edit_path)
        fill_in :discount_value_off, with: @new_value_off
        fill_in :discount_min_amount, with: @new_min_amount
        find("input[value=\"#{@new_discount_type}\"]", visible: false).click

        click_on "Update Discount"
        expect(current_path).to eq(@index_path)
        expect(page).to have_content("Discount ##{@discount.id} has been updated.")
        @sign_in.call
        visit(@index_path)
        within "#discount-#{Discount.last.id}" do
          expect(page).to have_content("$#{@new_value_off} off orders of $#{@new_min_amount} or more.")
        end
      end
    end



    describe 'I can delete a discount' do
      before(:each) do
        @merchant = create(:merchant)
        @admin = create(:admin)
      end
      scenario 'as an admin' do
        @sign_in = Proc.new do
          allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@admin.reload)
        end
        @index_path = admin_merchant_discounts_path(@merchant)
      end
      scenario 'as a merchant' do
        @sign_in = Proc.new do
          allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@merchant.reload)
        end
        @index_path = dashboard_discounts_path
      end
      after(:each) do
        @discount = create(:discount, user: @merchant, discount_type: "percent")
        @surviving_discount = create(:discount, user: @merchant, discount_type: "percent")
        @sign_in.call
        visit(@index_path)
        within "#discount-#{@discount.id}" do
          click_on "Delete"
        end
        expect(page).to have_content("Discount ##{@discount.id} has been deleted.")
        expect(current_path).to eq(@index_path)
        @sign_in.call
        visit(@index_path)
        expect(page).to have_content("#{@surviving_discount.value_off}% off orders of #{@surviving_discount.min_amount} items or more.")
        expect(page).to_not have_content("#{@discount.value_off}% off orders of #{@discount.min_amount} items or more.")
      end
    end
  end
end
