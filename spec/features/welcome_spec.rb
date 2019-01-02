require 'rails_helper'

RSpec.describe 'Welcome page', type: :feature do
  it 'displays a simple welcome message' do
    visit root_path
    expect(page).to have_content('Welcome to our ficticious "Little Shop of Orders" e-commerce platform.')
  end
end
