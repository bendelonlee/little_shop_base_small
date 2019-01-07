class Admin::DashboardController < Admin::BaseController
  def index
    @pcd = Item.price_candlestick_data
  end
end
