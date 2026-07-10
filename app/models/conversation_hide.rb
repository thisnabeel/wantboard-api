# frozen_string_literal: true

class ConversationHide < ApplicationRecord
  self.primary_key = %i[offer_id user_id]

  belongs_to :offer
  belongs_to :user

  def self.hide!(offer_id:, user_id:)
    record = find_or_initialize_by(offer_id: offer_id, user_id: user_id)
    record.hidden_at = Time.current
    record.save!
  end
end
