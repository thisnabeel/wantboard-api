# frozen_string_literal: true

class User < ApplicationRecord
  has_secure_password

  has_many :listings, dependent: :destroy
  has_many :offers, foreign_key: :offerer_id, dependent: :destroy, inverse_of: :offerer
  has_many :messages, foreign_key: :sender_id, dependent: :destroy, inverse_of: :sender
  has_many :conversation_reads, dependent: :destroy
  has_many :conversation_hides, dependent: :destroy

  validates :name, :email, presence: true
  validates :email, uniqueness: { case_sensitive: false }
  validates :password, length: { minimum: 6 }, if: -> { password.present? }

  before_validation :normalize_email

  def listing_count
    listings.count
  end

  private

  def normalize_email
    self.email = email.to_s.downcase.strip
  end
end
