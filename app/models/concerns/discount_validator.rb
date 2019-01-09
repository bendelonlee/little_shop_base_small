class DiscountValidator < ActiveModel::Validator

  def validate(record)
    percent_off_below_99(record)
    dollar_off_less_than_min_amount(record)
    min_amount_unique_to_merchant(record)
    value_off_unique_to_merchant(record)
  end

  def percent_off_below_99(record)
    if record.value_off && record.value_off > 99 && record.discount_type == "percent"
      record.errors.add(:value_off, "Discount percentage cannot be greater than 99")
    end
  end

  def dollar_off_less_than_min_amount(record)
    if record.min_amount && record.value_off && record.value_off >= record.min_amount && record.discount_type == "dollar"
      record.errors.add(:min_amount, "Dollars off must be less than the minimum amount")
    end
  end

  def min_amount_unique_to_merchant(record)
    if Discount.where.not(id: record.id).find_by(min_amount: record.min_amount, user_id: record.user_id)
      record.errors.add(:min_amount, "You already have a discount with that minimum amount")
    end
  end

  def value_off_unique_to_merchant(record)
    if Discount.where.not(id: record.id).find_by(value_off: record.value_off, user_id: record.user_id)
      record.errors.add(:value_off, "You already have a discount with that value off")
    end
  end

end
