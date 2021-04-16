# frozen_string_literal: true

require 'rails_helper'
require 'rspec_api_documentation/dsl'

resource 'Invitations' do
  explanation 'Invitations methods'

  post '/api/invitations' do
    let(:user) { create :user }
    let(:jwt) { RailsJwtAuth::JwtManager.encode user.to_token_payload }
    before { header 'Authorization', "Bearer #{jwt}" }

    let(:email) { 'new@example.com' }
    with_options scope: :invitation, required: true do
      parameter :email, 'User email'
    end

    context '204' do
      example_request('Create invitation') do
        expect(status).to eq(204)
      end
    end

    context '422' do
      before do
        create :user, email: email
      end
      example('Invite already invited', document: false) do
        do_request
        expect(status).to eq(422)
      end
    end
  end

  patch '/api/invitations/:invitation_token' do
    before do
      create :user, invitation_token: 'token', invitation_sent_at: Time.current
    end

    let(:password) { 'password' }
    let(:password_confirmation) { 'password' }
    let(:invitation_token) { 'token' }

    with_options scope: :invitation, required: true do
      parameter :password, 'User password'
      parameter :password_confirmation, 'User password confirmation'
    end

    context '204' do
      example_request('Accept invitation') do
        expect(status).to eq(204)
      end
    end
  end
end
