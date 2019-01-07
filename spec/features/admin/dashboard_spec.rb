require "rails_helper"

describe 'The Admin Dashboad' do
  describe 'has statistics' do
    it 'shows a candlestick plot of the item prices on the site' do
      within "#admin-statistics" do
        expect(page).to have_css("#item_price_candle_stick")
      end
    end
  end
end
