# frozen_string_literal: true

class InviteController < ApplicationController
  CREATE_MESSAGE = 'Create invite link'

  def show
    user = User.find_by!(address: address)
    render json: { invite_code: user.invite_code }
  end

  def create
    begin
      public_key = Eth::Key.personal_recover(CREATE_MESSAGE, signature)
      address_from_signature = Eth::Utils.public_key_to_address(public_key)
      raise :invalid if address_from_signature != address
    rescue StandardError
      return render json: { errors: { signature: [:invalid] } },
                    status: :unprocessable_entity
    end
    user = User.find_or_create_by!(address: address_from_signature)
    user.create_invite_code!

    render json: { invite_code: user.invite_code }, status: :created
  end

  def link
    inviter = User.find_by(invite_code: invite_code)
    if inviter.nil?
      return render json: { errors: { invite_code: [:invalid] } },
                    status: :unprocessable_entity
    end

    user = User.find_or_create_by!(address: address)
    if user.inviter_id.present? && user.inviter_id != inviter.id
      return render json: { errors: { user: [:already_linked] } },
                    status: :unprocessable_entity
    end

    if inviter.id == user.id
      return render json: { errors: { user: [:same_use] } },
                    status: :unprocessable_entity
    end

    user.update!(inviter_id: inviter.id)

    head :accepted
  end

  private

  def signature
    params.require(:signature)
  end

  def address
    params.require(:address)
  end

  def invite_code
    params[:invite_code] || cookies['invite_code']
  end
end
