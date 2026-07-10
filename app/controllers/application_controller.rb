# frozen_string_literal: true

class ApplicationController < ActionController::API
  include Authenticatable

  rescue_from ActiveRecord::RecordNotFound, with: :not_found

  private

  def render_error(message, status:)
    render json: { error: message }, status: status
  end

  def not_found
    render_error("Not found", status: :not_found)
  end
end
