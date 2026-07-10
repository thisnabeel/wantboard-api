# frozen_string_literal: true

class Message < ApplicationRecord
  belongs_to :offer
  belongs_to :sender, class_name: "User", inverse_of: :messages

  validates :content, length: { maximum: 1000 }
  validate :content_or_image_present, on: :create

  scope :chronological, -> { order(created_at: :asc) }
  scope :newest_first, -> { order(created_at: :desc) }

  private

  def content_or_image_present
    return if content.present? || image_base64.present?

    errors.add(:base, "content or imageBase64 is required")
  end
end
