# frozen_string_literal: true

require 'rails_helper'
require 'rspec_api_documentation/dsl'

resource 'Sessions' do
  explanation 'Sessions methods'

  let!(:user) { create :user, :confirmed }
  let(:email) { user.email }
  let(:password) { 'password' }
  let(:google_auth_code) { nil }
  let(:session) do
    {
      email: email,
      password: password,
      google_auth_code: google_auth_code
    }
  end

  post '/api/session' do
    with_options scope: :session, required: true do
      parameter :email, 'User email'
      parameter :password, 'User password'
      parameter :google_auth_code, 'Google auth code. Required if user enabled.'
    end

    with_options scope: :session do
      response_field :jwt, 'JWT token'
      response_field :email, 'User email'
    end

    context '201' do
      example_request('Create session (Sign in)') do
        expect(status).to eq(201)
        body = JSON.parse(response_body)
        expect(body['session']).to match_json_schema(:session)
      end
    end

    context '422' do
      let(:password) { 'incorrect_password' }
      example('Create session with wrong password', document: false) do
        do_request
        expect(status).to eq(422)
      end
    end

    context '422' do
      let(:email) { 'incorrect@example.com' }
      example('Create session with wrong email', document: false) do
        do_request
        expect(status).to eq(422)
      end
    end
  end

  delete '/api/session' do
    let(:jwt) { RailsJwtAuth::JwtManager.encode user.to_token_payload }

    context '204' do
      before { header 'Authorization', "Bearer #{jwt}" }
      example_request('Delete session (Sign out)') do
        expect(status).to eq(204)
      end
    end
    context '422' do
      example('Delete session without valid token', document: false) do
        do_request
        expect(status).to eq(401)
      end
    end
  end
end
