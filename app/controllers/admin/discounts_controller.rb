class Admin::DiscountsController < ApplicationController

  def index
    @merchant = User.find(params[:merchant_id])
    @discounts = @merchant.discounts
    @new_path = new_admin_merchant_discount_path(@merchant)
    @edit_path = Proc.new { |discount| edit_admin_merchant_discount_path(@merchant, discount) }
    @discount_path = Proc.new { |discount| admin_merchant_discount_path(@merchant, discount) }
    render "/dashboard/discounts/index"
  end

  def show
    @merchant = User.find(params[:merchant_id])
    @discount = Discount.find(params[:id])
    @oiq = OrderItem.quantity_distribution
    @your_oiq = @merchant.oi_quantity_distribution
    @qbd = @merchant.oi_quant_d_before_discount(@discount)
    @qad = @merchant.oi_quant_d_after_discount(@discount)
    @discount_path = Proc.new { |discount| admin_merchant_discount_path(@merchant, discount) }
    @edit_path = Proc.new { |discount| edit_admin_merchant_discount_path(@merchant, discount) }
    render "/dashboard/discounts/show"
  end

  def new
    @merchant = User.find(params[:merchant_id])
    @discount = Discount.new
    @form_path = Proc.new{ [:admin, @merchant, @discount] }
    if @merchant.discounts.count > 0
      @discount_type = @merchant.discounts.first.discount_type
    end
    render "/dashboard/discounts/new"
  end

  def edit
    @merchant = User.find(params[:merchant_id])
    @discount = Discount.find(params[:id])
    @form_path = Proc.new{ [:admin, @merchant, @discount] }
    if @merchant.discounts.count > 1
      @discount_type = @merchant.discounts.first.discount_type
    end
    render "/dashboard/discounts/new"
  end
end
