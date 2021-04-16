# frozen_string_literal: true

require 'rails_helper'

RSpec.describe InviteController, type: :controller do
  let(:address) { '0x311650e2605dB62107129F5EC557338c28EA16a9' }

  describe 'create' do
    subject { post :create, params: { signature: signature, address: address } }

    context 'ok' do
      let(:signature) do
        '0x4088cb910bc649bc2ff5c4c8363c03ebdcad6b1d6916fd2128f51ffe40fc5b531a7af65fecaacc3b94923e6e7fe72ab6e8a3ccb05fb108e2ceb4265b6d91c6701c'
      end
      it { expect { subject }.to change { User.count }.by(1) }
      it do
        subject
        expect(response.status).to eq(201)
        expect(User.last.address).to eq(address)
        expect(JSON.parse(response.body))
          .to eq({ 'invite_code' => User.last.invite_code })
      end
    end
    context 'invalid' do
      let(:signature) do
        '0x4088cb910bc649bc2ff5c4c8363c03ebdcad6b1d6916fd2128f51ffe40fc5b531a7af65fecaacc3b94923e6e7fe72ab6e8a3ccb05fb108e2ceb4265b6d91c6701a'
      end
      it do
        subject
        expect(response.status).to eq(422)
        expect(JSON.parse(response.body))
          .to eq({ 'errors' => { 'signature' => ['invalid'] } })
      end
    end

    context 'there are user' do
      let(:signature) do
        '0x4088cb910bc649bc2ff5c4c8363c03ebdcad6b1d6916fd2128f51ffe40fc5b531a7af65fecaacc3b94923e6e7fe72ab6e8a3ccb05fb108e2ceb4265b6d91c6701c'
      end
      let!(:user) { create :user, address: address, invite_code: 'code' }
      it { expect { subject }.not_to change { User.count } }
      it do
        subject
        expect(response.status).to eq(201)
        expect(JSON.parse(response.body))
          .to eq({ 'invite_code' => user.invite_code })
      end
    end
  end

  describe 'show' do
    subject { get :show, params: { address: address } }

    context 'not found' do
      it do
        subject
        expect(response.status).to eq(404)
      end
    end

    context 'found' do
      let!(:user) { create :user, address: address, invite_code: 'code' }

      it do
        subject
        expect(response.status).to eq(200)
        expect(JSON.parse(response.body))
          .to eq({ 'invite_code' => user.invite_code })
      end
    end
  end

  describe 'link' do
    let!(:inviter) { create :user, address: address, invite_code: 'uniq_code' }

    let(:new_address) { '0xDC13f8fcDefa7Af87EAd9519901E133e27b7bEA0' }
    subject do
      post :link, params: { address: new_address, invite_code: invite_code }
    end

    context 'invite code is invalid' do
      let(:invite_code) { 'invalid_code' }
      it do
        subject
        expect(response.status).to eq(422)
        expect(JSON.parse(response.body))
          .to eq({ 'errors' => { 'invite_code' => ['invalid'] } })
      end
    end

    context 'already linked' do
      let(:invite_code) { 'uniq_code' }
      before do
        create :user, address: new_address, inviter: create(:user)
      end
      it do
        subject
        expect(response.status).to eq(422)
        expect(JSON.parse(response.body))
          .to eq({ 'errors' => { 'user' => ['already_linked'] } })
      end
    end

    context 'ok' do
      let(:invite_code) { 'uniq_code' }
      it { expect { subject }.to change { User.count }.by(1) }
      it do
        subject
        expect(response.status).to eq(202)
        expect(User.last.inviter_id).to eq(inviter.id)
      end
    end
  end
end
