require "rails_helper"

describe 'discount show page' do

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
      when 'merchant'
        let(:sign_in) do
          Proc.new do
            allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@merchant.reload)
          end
        end
      end

      it 'it has a candlestick chart of order item quantitities before and after a discount was created' do
        within "#discount-statistics" do
          expect(page).to have_css("#discount-chart")
        end
      end

    end
  end
end
