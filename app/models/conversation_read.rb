# frozen_string_literal: true

class ConversationRead < ApplicationRecord
  self.primary_key = %i[offer_id user_id]

  belongs_to :offer
  belongs_to :user

  def self.mark_read!(offer_id:, user_id:, last_read_at:)
    record = find_or_initialize_by(offer_id: offer_id, user_id: user_id)
    record.last_read_at = last_read_at
    record.save!
  end
end
