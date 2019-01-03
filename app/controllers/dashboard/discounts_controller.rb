class Dashboard::DiscountsController < ApplicationController

  def new
    @discount = Discount.new
    @form_path = [:dashboard, @discount]
  end

  def create
    @discount = Discount.create(discount_params)
    flash[:success] = "Discount ##{@discount.id} has been created."
    redirect_to dashboard_discounts_path
  end

  def index
    @discounts = current_user.discounts
  end

  def edit
    @discount = Discount.find(params[:id])
    @form_path = [:dashboard, @discount]
  end

  def update
    discount = Discount.find(params[:id])
    discount.update(discount_params)
    flash[:success] = "Discount ##{discount.id} has been updated."
    redirect_to dashboard_discounts_path
  end

  def destroy
    @discount = Discount.find(params[:id])
    @discount.destroy
    flash[:success] = "Discount ##{@discount.id} has been deleted."
    redirect_to dashboard_discounts_path
  end

  private

  def discount_params
    dp = params.require(:discount).permit(:value_off, :min_amount, :discount_type)
    dp[:user] = current_user
    dp
  end
end
