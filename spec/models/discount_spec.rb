require "rails_helper"
describe Discount do
  it { should validate_presence_of :value_off }
  it { should validate_presence_of :discount_type }
  it { should validate_presence_of :min_amount }
  it { should belong_to :user }
end
