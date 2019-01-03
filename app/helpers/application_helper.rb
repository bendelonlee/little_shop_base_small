module ApplicationHelper

  def fulfillment_time(avg_f_time)
    if avg_f_time && avg_f_time.length > 0
      # 4 days 00:00:00.000000
      # 00:00:00.000000
      bits = avg_f_time.split(' ')
      time = bits[0]
      output = []

      if bits.length > 1
        time = bits[2]
        output << "#{bits[0]} #{bits[1]}"
      end

      time = time[0..time.length-8]
      granularity = ['hour', 'minute', 'second']

      time.split(':').each_with_index do |value, index|
        val = value.to_i
        if val > 0
          output << pluralize(val, granularity[index])
        end
      end
      output.join(', ')
    else
      'Unknown'
    end
  end

  def describe_discount(discount)
    case discount.discount_type
    when "percent"
      "Bulk Discount! Orders of #{discount.min_amount} items or more recieve #{discount.value_off}% off!"
    when "dollar"
      "Bulk Discount! Orders of $#{discount.min_amount} or more recieve $#{discount.value_off} off!"
    end
  end

end
