# frozen_string_literal: true

class ApplicationController < ActionController::Base
  skip_forgery_protection

  rescue_from(ActiveRecord::RecordNotFound) { head :not_found }
  rescue_from(ActiveRecord::RecordInvalid) do |e|
    render json: { errors: e.record.errors }, status: :unprocessable_entity
  end
end
