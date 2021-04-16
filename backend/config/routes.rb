# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)

  scope :api do
    resource :invite, controller: 'invite', only: [:show, :create] do
      post :link
    end
  end
end
