# frozen_string_literal: true

class ListingOffersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_listing

  def index
    unless @listing.user_id == current_user_id
      return render_error("Forbidden", status: :forbidden)
    end

    rows = @listing.offers.newest_first.includes(:offerer)
    counts = listing_counts_for(rows.map(&:offerer_id))

    render json: {
      offers: rows.map { |offer| Api::Presenters.offer(offer, listing_count: counts[offer.offerer_id] || 0) },
      total: rows.size
    }
  end

  def create
    if @listing.user_id == current_user_id
      return render_error("You cannot offer on your own listing", status: :forbidden)
    end

    price = params[:price]
    match_type = params[:matchType]
    description = params[:description]
    image_base64 = params[:imageBase64]

    if price.nil? || price.to_f.negative?
      return render_error("price must be a non-negative number", status: :bad_request)
    end
    unless Offer::MATCH_TYPES.include?(match_type)
      return render_error("matchType must be 'exact' or 'close_enough'", status: :bad_request)
    end
    if match_type == "close_enough" && description.to_s.strip.blank?
      return render_error("description is required for 'close_enough' offers", status: :bad_request)
    end

    clean_description = description.to_s.strip.presence
    price_label = "$#{price.to_f}"
    auto_message =
      case match_type
      when "exact"
        "How about this exactly for #{price_label}?"
      when "close_enough"
        if clean_description
          "How about this, but #{clean_description}, for #{price_label}?"
        else
          "How about this (close enough) for #{price_label}?"
        end
      end

    offer = nil
    ActiveRecord::Base.transaction do
      offer = @listing.offers.create!(
        offerer: current_user,
        price: price,
        match_type: match_type,
        description: clean_description,
        image_base64: image_base64,
        status: "pending"
      )
      offer.messages.create!(
        sender: current_user,
        content: auto_message,
        image_base64: image_base64
      )
    end

    render json: Api::Presenters.offer(offer, listing_count: current_user.listings.count), status: :created
  rescue ActiveRecord::RecordInvalid => e
    render_error(e.record.errors.full_messages.first || "Validation error", status: :bad_request)
  end

  private

  def set_listing
    @listing = Listing.find(params[:listing_id])
  rescue ActiveRecord::RecordNotFound
    render_error("Listing not found", status: :not_found)
  end

  def listing_counts_for(user_ids)
    Listing.where(user_id: user_ids).group(:user_id).count
  end
end
