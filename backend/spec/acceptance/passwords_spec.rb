# frozen_string_literal: true

require 'rails_helper'
require 'rspec_api_documentation/dsl'

resource 'Passwords' do
  explanation 'User password reset'

  let!(:user) { create :user, :confirmed }

  post '/api/passwords' do
    with_options scope: :password, required: true do
      parameter :email
    end

    let(:password) { { email: email } }

    context '204' do
      let(:email) { user.email }
      example_request('Send reset password email') do
        expect(status).to eq(204)
      end
    end

    context '422' do
      let(:email) { 'test@other.com' }
      example('Send reset password with wrong email', document: false) do
        do_request
        expect(status).to eq(422)
      end
    end
  end

  put '/api/passwords/:token' do
    with_options scope: :password, required: true do
      parameter :password, 'User password'
      parameter :password_confirmation, 'User password confirmation'
    end

    parameter :password, 'Scope. FIXME'

    before { user.send_reset_password_instructions }

    context '204' do
      let(:token) { user.reset_password_token }
      let(:password) do
        {
          password: 'qwe123',
          password_confirmation: 'qwe123'
        }
      end

      example_request('Reset user password') do
        expect(status).to eq(204)
      end
    end
    context '404' do
      let(:token) { 'testtesttest' }
      let(:password) do
        {
          password: 'qwe123',
          password_confirmation: 'qwe123'
        }
      end
      example('Reset user password without valid token', document: false) do
        do_request
        expect(status).to eq(404)
      end
    end
  end
end
