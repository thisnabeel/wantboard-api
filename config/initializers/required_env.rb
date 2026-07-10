# frozen_string_literal: true

if Rails.env.production? && ENV["SESSION_SECRET"].blank?
  raise "SESSION_SECRET must be set in config/application.yml"
end
