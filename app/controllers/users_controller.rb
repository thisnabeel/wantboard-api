# frozen_string_literal: true

class UsersController < ApplicationController
  def show
    user = User.find(params[:id])
    render json: Api::Presenters.public_user(user, listing_count: user.listing_count)
  rescue ActiveRecord::RecordNotFound
    render_error("User not found", status: :not_found)
  end
end
