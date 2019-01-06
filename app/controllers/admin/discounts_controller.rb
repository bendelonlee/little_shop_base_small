class Admin::DiscountsController < ApplicationController

  def index
    merchant = User.find(params[:merchant_id])
    @discounts = merchant.discounts
    @new_path = new_admin_merchant_discount_path(merchant)
    render "/dashboard/discounts/index"
  end

  def new
    @merchant = User.find(params[:merchant_id])
    @discount = Discount.new
    @form_path = [:admin, @merchant, @discount]
    render "/dashboard/discounts/new"
  end
end
