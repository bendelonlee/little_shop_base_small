require "rails_helper"

describe 'The Admin Dashboad' do
  before(:each) do
    @admin = create(:admin)
  end
  let(:sign_in) do
    Proc.new do
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@admin.reload)
    end
  end
  describe 'has statistics' do
    it 'shows a candlestick plot of the item prices on the site' do
      sign_in.call
      visit admin_dashboard_index_path
      within "#admin-statistics" do
        expect(page).to have_css("#item_price_candle_stick")
      end
    end
  end
end
