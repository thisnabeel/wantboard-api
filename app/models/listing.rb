# frozen_string_literal: true

class Listing < ApplicationRecord
  CATEGORIES = [
    "Electronics", "Clothing", "Furniture", "Books", "Sports",
    "Toys", "Home & Garden", "Vehicles", "Collectibles", "Other"
  ].freeze

  CONDITIONS = %w[new used any].freeze
  STATUSES = %w[open fulfilled].freeze

  belongs_to :user
  has_many :offers, dependent: :destroy

  validates :title, :description, :category, :condition, presence: true
  validates :category, inclusion: { in: CATEGORIES }
  validates :condition, inclusion: { in: CONDITIONS }
  validates :status, inclusion: { in: STATUSES }

  scope :open, -> { where(status: "open") }
  scope :newest_first, -> { order(created_at: :desc) }
end
