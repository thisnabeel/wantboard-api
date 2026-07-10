# frozen_string_literal: true

class OffersController < ApplicationController
  before_action :authenticate_user!

  def update
    offer = Offer.includes(:listing, :offerer).find(params[:id])
    status = params[:status]

    unless %w[accepted rejected].include?(status)
      return render_error("status must be 'accepted' or 'rejected'", status: :bad_request)
    end

    unless offer.listing.user_id == current_user_id
      return render_error("Forbidden", status: :forbidden)
    end

    offer.update!(status: status)
    render json: Api::Presenters.offer(offer, listing_count: offer.offerer.listings.count)
  rescue ActiveRecord::RecordNotFound
    render_error("Offer not found", status: :not_found)
  end
end
