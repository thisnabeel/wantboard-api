# frozen_string_literal: true

class Offer < ApplicationRecord
  MATCH_TYPES = %w[exact close_enough].freeze
  STATUSES = %w[pending accepted rejected].freeze

  belongs_to :listing
  belongs_to :offerer, class_name: "User", inverse_of: :offers
  has_many :messages, dependent: :destroy
  has_many :conversation_reads, dependent: :destroy
  has_many :conversation_hides, dependent: :destroy

  validates :price, numericality: { greater_than_or_equal_to: 0 }
  validates :match_type, inclusion: { in: MATCH_TYPES }
  validates :status, inclusion: { in: STATUSES }

  scope :newest_first, -> { order(created_at: :desc) }

  def participant?(user_id)
    offerer_id == user_id || listing.user_id == user_id
  end

  def other_user_id(for_user_id)
    offerer_id == for_user_id ? listing.user_id : offerer_id
  end
end
