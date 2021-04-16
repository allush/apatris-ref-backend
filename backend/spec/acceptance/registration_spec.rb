# frozen_string_literal: true

require 'rails_helper'
require 'rspec_api_documentation/dsl'

resource 'Registration' do
  explanation 'Registration methods'

  let(:email) { 'new@example.com' }
  let(:password) { 'password' }

  post '/api/registration' do
    with_options scope: :user, required: true do
      parameter :email, 'User email'
      parameter :password, 'User password'
    end

    with_options scope: :user do
      response_field :id, 'ID'
      response_field :email, 'User email'
    end

    context '201' do
      example_request('Create user') do
        expect(status).to eq(201)
        body = JSON.parse(response_body)
        expect(body['user']).to match_json_schema(:user)
      end
    end

    context 'Ref cookie passed' do
      let(:inviter) { create :user }
      before do
        allow_any_instance_of(RegistrationsController)
          .to receive(:invite_code)
          .and_return(inviter.invite_code)
      end
      example('Register with ref code', document: false) do
        do_request
        expect(status).to eq(201)
        expect(User.last.reload.inviter_id).to eq(inviter.id)
      end
    end

    context '422' do
      before do
        create :user, email: email
      end
      example('Register with taken email', document: false) do
        do_request
        expect(status).to eq(422)
      end
    end
  end
end
