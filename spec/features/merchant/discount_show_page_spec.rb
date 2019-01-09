require "rails_helper"

describe 'discount show page' do

  ['merchant', 'admin'].each do |whosviewing|
    describe "as #{whosviewing}," do
      before(:each) do
        @merchant = create(:merchant)
        @admin = create(:admin)
        @discount = create(:discount, user: @merchant)
      end
      case whosviewing
      when 'admin'
        let(:sign_in) do
          Proc.new do
            allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@admin.reload)
            @merchant.reload
          end
        end
        let(:discount_path) do
          admin_merchant_discount_path(@merchant, @discount)
        end
      when 'merchant'
        let(:sign_in) do
          Proc.new do
            allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@merchant.reload)
          end
        end
        let(:discount_path) do
          dashboard_discount_path(@discount)
        end
      end

      it 'it has a candlestick chart of order item quantitities before and after a discount was created' do
        sign_in.call
        visit discount_path
        within "#discount-statistics" do
          expect(page).to have_css("#discount-chart")
        end
      end

      it 'has discount info' do
        sign_in.call
        visit discount_path
        expect(page).to have_content("Created at: #{@discount.created_at}")
      end
    end
  end
end
