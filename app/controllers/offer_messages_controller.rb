# frozen_string_literal: true

class OfferMessagesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_offer

  def index
    return render_error("Forbidden", status: :forbidden) unless @offer.participant?(current_user_id)

    messages = @offer.messages.chronological
    if messages.any?
      ConversationRead.mark_read!(
        offer_id: @offer.id,
        user_id: current_user_id,
        last_read_at: messages.last.created_at
      )
    end

    other_user = User.find(@offer.other_user_id(current_user_id))
    render json: {
      messages: messages.map { |message| Api::Presenters.message(message) },
      otherUser: Api::Presenters.public_user(other_user, listing_count: 0),
      offererId: @offer.offerer_id
    }
  end

  def create
    return render_error("Forbidden", status: :forbidden) unless @offer.participant?(current_user_id)

    content = params[:content].to_s.strip
    image_base64 = params[:imageBase64].to_s.strip.presence

    if params.key?(:content) && !params[:content].is_a?(String)
      return render_error("content must be a string", status: :bad_request)
    end
    if params.key?(:imageBase64) && !params[:imageBase64].nil? && !params[:imageBase64].is_a?(String)
      return render_error("imageBase64 must be a string", status: :bad_request)
    end
    if content.length > 1000
      return render_error("content must be at most 1000 characters", status: :bad_request)
    end
    if content.blank? && image_base64.blank?
      return render_error("content or imageBase64 is required", status: :bad_request)
    end

    message = @offer.messages.create!(
      sender_id: current_user_id,
      content: content,
      image_base64: image_base64
    )

    render json: Api::Presenters.message(message), status: :created
  rescue ActiveRecord::RecordInvalid => e
    render_error(e.record.errors.full_messages.first || "Validation error", status: :bad_request)
  end

  private

  def set_offer
    @offer = Offer.includes(:listing).find(params[:offer_id])
  rescue ActiveRecord::RecordNotFound
    render_error("Not found", status: :not_found)
  end
end
