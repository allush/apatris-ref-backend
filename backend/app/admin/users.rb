# frozen_string_literal: true

ActiveAdmin.register User do
  filter :address
  filter :invite_code
  filter :inviter
  filter :created_at

  index do
    selectable_column
    id_column
    column :address
    column :invite_code
    column :inviter
    column :created_at
    actions
  end

  actions :index, :show
end
