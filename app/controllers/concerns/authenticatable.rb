# frozen_string_literal: true

module Authenticatable
  extend ActiveSupport::Concern

  included do
    attr_reader :current_user_id
  end

  def authenticate_user!
    auth_header = request.headers["Authorization"]
    unless auth_header&.start_with?("Bearer ")
      return render_error("Unauthorized", status: :unauthorized)
    end

    token = auth_header.delete_prefix("Bearer ")
    user_id = JwtService.decode(token)
    unless user_id
      return render_error("Invalid or expired token", status: :unauthorized)
    end

    @current_user_id = user_id
  end

  def current_user
    return @current_user if defined?(@current_user)

    @current_user = User.find_by(id: current_user_id) if current_user_id
  end
end
