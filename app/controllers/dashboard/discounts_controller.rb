class Dashboard::DiscountsController < ApplicationController
  before_action :set_discount_type_for_edit, only: [:edit, :update]
  before_action :set_discount_type_for_new, only: [:new, :create]

  def new
    @discount = Discount.new
    @form_path = [:dashboard, @discount]
  end

  def create
    @discount = Discount.new(discount_params)
    if @discount.save
      flash[:success] = "Discount ##{@discount.id} has been created."

      redirect_to dashboard_discounts_path
    else
      @form_path = [:dashboard, @discount]
      render :new
    end
  end

  def index
    @discounts = current_user.discounts
  end

  def edit
    @discount = Discount.find(params[:id])
    @form_path = [:dashboard, @discount]
  end

  def update
    @discount = Discount.find(params[:id])
    @discount.update(discount_params)
    if @discount.save
      flash[:success] = "Discount ##{@discount.id} has been updated."
      redirect_to dashboard_discounts_path
    else
      @form_path = [:dashboard, @discount]
      render :edit
    end
  end

  def destroy
    @discount = Discount.find(params[:id])
    @discount.destroy
    flash[:success] = "Discount ##{@discount.id} has been deleted."
    redirect_to dashboard_discounts_path
  end

  private

  def discount_params
    if @discount_type
      params[:discount][:discount_type] = @discount_type
    end
    dp = params.require(:discount).permit(:value_off, :min_amount, :discount_type)
    dp[:user] = current_user
    dp
  end

  def set_discount_type_for_new
    if current_user.discounts.count > 0
      @discount_type = current_user.discounts.first.discount_type
    end
  end

  def set_discount_type_for_edit
    if current_user.discounts.count > 1
      @discount_type = current_user.discounts.first.discount_type
    end
  end
end
