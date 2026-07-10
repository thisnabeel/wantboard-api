# frozen_string_literal: true

class AuthController < ApplicationController
  before_action :authenticate_user!, only: :me

  def register
    unless params[:name].present? && params[:email].present? && params[:password].present?
      return render_error("name, email, and password are required", status: :bad_request)
    end

    user = User.new(register_params)
    if user.save
      render json: auth_response(user, listing_count: 0), status: :created
    elsif user.errors.of_kind?(:email, :taken)
      render_error("Email already in use", status: :conflict)
    else
      render_error(user.errors.full_messages.first || "Validation error", status: :bad_request)
    end
  end

  def login
    unless params[:email].present? && params[:password].present?
      return render_error("email and password are required", status: :bad_request)
    end

    user = User.find_by(email: params[:email].to_s.downcase.strip)
    unless user&.authenticate(params[:password].to_s)
      return render_error("Invalid credentials", status: :unauthorized)
    end

    render json: auth_response(user, listing_count: user.listing_count)
  end

  def me
    user = current_user
    return render_error("User not found", status: :unauthorized) unless user

    render json: Api::Presenters.user(user, listing_count: user.listing_count)
  end

  private

  def register_params
    params.permit(:name, :email, :password, :location)
  end

  def auth_response(user, listing_count:)
    {
      token: JwtService.encode(user.id),
      user: Api::Presenters.user(user, listing_count: listing_count)
    }
  end
end
