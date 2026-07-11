# frozen_string_literal: true

# Railway's raw ENV editor sometimes stores values with wrapping quotes.
%w[RAILS_ENV DATABASE_URL RAILS_MASTER_KEY SESSION_SECRET].each do |key|
  value = ENV[key]
  next if value.blank?

  stripped = value.strip.delete_prefix('"').delete_suffix('"').delete_prefix("'").delete_suffix("'").strip
  ENV[key] = stripped if stripped != value
end
