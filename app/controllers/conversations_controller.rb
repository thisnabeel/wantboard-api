# frozen_string_literal: true

class ConversationsController < ApplicationController
  before_action :authenticate_user!

  def index
    offers = Offer.includes(:listing, :offerer, listing: :user)
                  .joins(:listing)
                  .where("offers.offerer_id = :uid OR listings.user_id = :uid", uid: current_user_id)

    threads = offers.filter_map do |offer|
      build_thread(offer)
    end

    threads.sort_by! { |thread| thread[:updatedAt] }
    threads.reverse!

    render json: { conversations: threads }
  end

  def destroy
    offer = Offer.includes(:listing).find(params[:offer_id])
    unless offer.participant?(current_user_id)
      return render_error("Forbidden", status: :forbidden)
    end

    ConversationHide.hide!(offer_id: offer.id, user_id: current_user_id)
    head :no_content
  rescue ActiveRecord::RecordNotFound
    render_error("Not found", status: :not_found)
  end

  private

  def build_thread(offer)
    last_message = offer.messages.newest_first.first
    return nil unless last_message

    hide = ConversationHide.find_by(offer_id: offer.id, user_id: current_user_id)
    if hide && last_message.created_at <= hide.hidden_at
      return nil
    end

    other_user_id = offer.other_user_id(current_user_id)
    other_user = User.find_by(id: other_user_id)
    return nil unless other_user

    read = ConversationRead.find_by(offer_id: offer.id, user_id: current_user_id)
    last_read_at = read&.last_read_at || Time.at(0)

    unread_count = offer.messages.where.not(sender_id: current_user_id)
                        .where("created_at > ?", last_read_at)
                        .count

    Api::Presenters.conversation_thread(
      offer: offer,
      listing: offer.listing,
      other_user: other_user,
      last_message: last_message,
      unread_count: unread_count
    )
  end
end
