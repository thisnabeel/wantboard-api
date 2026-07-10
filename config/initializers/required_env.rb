# frozen_string_literal: true

if Rails.env.production? && ENV["SESSION_SECRET"].blank?
  raise "SESSION_SECRET must be set (Railway service variable or config/application.yml)"
end
