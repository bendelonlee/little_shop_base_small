require 'rails_helper'

RSpec.describe 'Welcome page', type: :feature do
  it 'displays a simple welcome message' do
    visit root_path
<<<<<<< HEAD
    expect(page).to have_content('Welcome')
=======
    expect(page).to have_content('Welcome to our ficticious "Little Shop of Orders" e-commerce platform.')
>>>>>>> 208a92a0a34f2ef5e997eb8286bbe71fbd6f06fb
  end
end
