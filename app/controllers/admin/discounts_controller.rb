class Admin::DiscountsController < ApplicationController

  def index
    @merchant = User.find(params[:merchant_id])
    @discounts = @merchant.discounts
    @new_path = new_admin_merchant_discount_path(@merchant)
    @edit_path = Proc.new { |discount| edit_admin_merchant_discount_path(@merchant, discount) }
    @delete_path = Proc.new { |discount| admin_merchant_discount_path(@merchant, discount) }
    render "/dashboard/discounts/index"
  end

  def new
    @merchant = User.find(params[:merchant_id])
    @discount = Discount.new
    @form_path = [:admin, @merchant, @discount]
    if @merchant.discounts.count > 0
      @discount_type = @merchant.discounts.first.discount_type
    end
    render "/dashboard/discounts/new"
  end

  def edit
    @merchant = User.find(params[:merchant_id])
    @discount = Discount.find(params[:id])
    @form_path = [:admin, @merchant, @discount]
    if @merchant.discounts.count > 1
      @discount_type = @merchant.discounts.first.discount_type
    end
    render "/dashboard/discounts/new"
  end
end
