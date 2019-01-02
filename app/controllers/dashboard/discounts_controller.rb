class Dashboard::DiscountsController < ApplicationController
  def index
    @discounts = current_user.discounts
  end
end
