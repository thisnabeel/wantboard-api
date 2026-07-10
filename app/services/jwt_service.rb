# frozen_string_literal: true

module JwtService
  module_function

  def secret
    ENV.fetch("SESSION_SECRET") { raise "SESSION_SECRET environment variable is required but not set." }
  end

  def encode(user_id)
    payload = {
      userId: user_id,
      exp: 30.days.from_now.to_i
    }
    JWT.encode(payload, secret, "HS256")
  end

  def decode(token)
    payload, = JWT.decode(token, secret, true, algorithm: "HS256")
    payload.fetch("userId")
  rescue JWT::DecodeError
    nil
  end
end
