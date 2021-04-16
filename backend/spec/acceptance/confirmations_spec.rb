# frozen_string_literal: true

require 'rails_helper'
require 'rspec_api_documentation/dsl'

resource 'Confirmations' do
  explanation 'Confirmations methods'

  let(:email) { 'new@example.com' }
  before do
    create :user, confirmation_token: 'token',
                  confirmation_sent_at: Time.current,
                  email: email
  end

  post '/api/confirmations' do
    let(:confirmation) do
      {
        email: email
      }
    end

    with_options scope: :confirmation, required: true do
      parameter :email, 'User email'
    end

    context '204' do
      example_request('Resend confirmation email') do
        expect(status).to eq(204)
      end
    end
  end

  patch '/api/confirmations/:token' do
    let(:token) { 'token' }

    context '204' do
      example_request('Confirm account') do
        expect(status).to eq(204)
      end
    end
  end
end
