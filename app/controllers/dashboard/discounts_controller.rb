class Dashboard::DiscountsController < ApplicationController #Dashboard::BaseController
  before_action :handle_admin_or_merchant_user, except: [:index]

  before_action :set_discount_type_for_edit, only: [:edit, :update]
  before_action :set_discount_type_for_new, only: [:new, :create]


  def new
    @discount = Discount.new
  end

  def create
    @discount = Discount.new(discount_params)
    if @discount.save
      flash[:success] = "Discount ##{@discount.id} has been created."
      redirect_to @index_path
    else
      if current_admin?

      else
      end

      render :new
    end
  end

  def index
    @discounts = current_user.discounts
    @new_path = new_dashboard_discount_path
    @edit_path = Proc.new { |discount| edit_dashboard_discount_path(discount) }
    @delete_path = Proc.new { |discount| dashboard_discount_path(discount) }
  end

  def edit
    @discount = Discount.find(params[:id])
  end

  def update
    @discount = Discount.find(params[:id])
    @discount.update(discount_params)
    if @discount.save
      flash[:success] = "Discount ##{@discount.id} has been updated."
      redirect_to @index_path
    else
      render :edit
    end
  end

  def destroy
    @discount = Discount.find(params[:id])
    @discount.destroy
    flash[:success] = "Discount ##{@discount.id} has been deleted."
    redirect_to @index_path
  end

  private

  def handle_admin_or_merchant_user
    if current_admin?
      merchant_id = params[:merchant_id] || params[:id] || params[:user_id]
      @merchant = User.find(merchant_id)
      @form_path = Proc.new { [:admin, @merchant, @discount] }
      @index_path = admin_merchant_discounts_path(@merchant)
    else
      @merchant = current_user
      @form_path = Proc.new{ [:dashboard, @discount] }
      @index_path = dashboard_discounts_path
    end
  end

  def discount_params
    if @discount_type
      params[:discount][:discount_type] = @discount_type
    end
    dp = params.require(:discount).permit(:value_off, :min_amount, :discount_type)
    dp[:user] = @merchant
    dp
  end

  def set_discount_type_for_new
    if @merchant.discounts.count > 0
      @discount_type = @merchant.discounts.first.discount_type
    end
  end

  def set_discount_type_for_edit
    if @merchant.discounts.count > 1
      @discount_type = @merchant.discounts.first.discount_type
    end
  end
end
