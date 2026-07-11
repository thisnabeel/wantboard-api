# frozen_string_literal: true

class ListingsController < ApplicationController
  before_action :authenticate_user!, only: %i[my create update destroy]
  before_action :set_listing, only: %i[show update destroy]
  before_action :authorize_owner!, only: %i[update destroy]

  def index
    listings = Listing.open.newest_first
    listings = listings.where(category: params[:category]) if params[:category].present?
    listings = listings.where(condition: params[:condition]) if params[:condition].present?
    listings = listings.where("title ILIKE ?", "%#{params[:search]}%") if params[:search].present?

    limit = [params.fetch(:limit, 20).to_i, 100].min
    offset = params.fetch(:offset, 0).to_i
    total = listings.count
    rows = listings.includes(:user).offset(offset).limit(limit)

    counts = listing_counts_for(rows.map(&:user_id))

    render json: {
      listings: rows.map { |listing| serialize_listing(listing, counts[listing.user_id] || 0) },
      total: total
    }
  end

  def my
    user = current_user
    return render_error("User not found", status: :unauthorized) unless user

    rows = user.listings.newest_first
    render json: {
      listings: rows.map { |listing| serialize_listing(listing, rows.size) },
      total: rows.size
    }
  end

  def show
    count = @listing.user.listings.count
    render json: serialize_listing(@listing, count)
  end

  def create
    unless params[:title].present? && params[:description].present? && params[:category].present? && params[:condition].present?
      return render_error("title, description, category, and condition are required", status: :bad_request)
    end

    listing = current_user.listings.new(create_params.merge(status: "open"))
    if listing.save
      render json: serialize_listing(listing, current_user.listings.count), status: :created
    else
      render_error(listing.errors.full_messages.first || "Validation error", status: :bad_request)
    end
  end

  def update
    if @listing.update(update_params)
      render json: serialize_listing(@listing, current_user.listings.count)
    else
      render_error(@listing.errors.full_messages.first || "Validation error", status: :bad_request)
    end
  end

  def destroy
    @listing.destroy!
    head :no_content
  end

  private

  def set_listing
    @listing = Listing.includes(:user).find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render_error("Listing not found", status: :not_found)
  end

  def authorize_owner!
    return if @listing.user_id == current_user_id

    render_error("Forbidden", status: :forbidden)
  end

  def create_params
    map_listing_attributes(params.permit(:title, :description, :category, :condition, :budget, :location, :isUrgent))
  end

  def update_params
    attrs = map_listing_attributes(params.permit(:title, :description, :category, :condition, :budget, :location, :isUrgent, :status))
    attrs[:updated_at] = Time.current if attrs.present?
    attrs
  end

  def map_listing_attributes(permitted)
    attrs = permitted.to_h.symbolize_keys
    attrs[:is_urgent] = attrs.delete(:isUrgent) if attrs.key?(:isUrgent)
    attrs
  end

  def listing_counts_for(user_ids)
    Listing.where(user_id: user_ids).group(:user_id).count
  end

  def serialize_listing(listing, listing_count)
    Api::Presenters.listing(listing, listing_count: listing_count)
  end
end
