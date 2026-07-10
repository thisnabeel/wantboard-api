# frozen_string_literal: true

module Api
  module Presenters
    module_function

    def public_user(user, listing_count: nil)
      {
        id: user.id,
        name: user.name,
        location: user.location,
        bio: user.bio,
        avatarUrl: user.avatar_url,
        listingCount: listing_count.nil? ? user.listings.count : listing_count,
        createdAt: user.created_at
      }
    end

    def user(user, listing_count: nil)
      public_user(user, listing_count: listing_count).merge(email: user.email)
    end

    def listing(listing, user: nil, listing_count: nil)
      owner = user || listing.user
      count = listing_count.nil? ? owner.listings.count : listing_count

      {
        id: listing.id,
        userId: listing.user_id,
        title: listing.title,
        description: listing.description,
        category: listing.category,
        condition: listing.condition,
        budget: listing.budget&.to_f,
        location: listing.location,
        isUrgent: listing.is_urgent,
        status: listing.status,
        user: public_user(owner, listing_count: count),
        createdAt: listing.created_at,
        updatedAt: listing.updated_at
      }
    end

    def offer(offer, offerer: nil, listing_count: nil)
      person = offerer || offer.offerer
      count = listing_count.nil? ? person.listings.count : listing_count

      {
        id: offer.id,
        listingId: offer.listing_id,
        offererId: offer.offerer_id,
        price: offer.price.to_f,
        matchType: offer.match_type,
        description: offer.description,
        imageBase64: offer.image_base64,
        status: offer.status,
        offerer: public_user(person, listing_count: count),
        createdAt: offer.created_at
      }
    end

    def message(message)
      {
        id: message.id,
        offerId: message.offer_id,
        senderId: message.sender_id,
        content: message.content,
        imageBase64: message.image_base64,
        createdAt: message.created_at
      }
    end

    def conversation_thread(offer:, listing:, other_user:, last_message:, unread_count:)
      {
        offerId: offer.id,
        offerPrice: offer.price.to_f,
        matchType: offer.match_type,
        otherUser: public_user(other_user, listing_count: 0),
        listing: {
          id: listing.id,
          title: listing.title,
          budget: listing.budget&.to_f
        },
        lastMessage: {
          content: last_message.content,
          senderId: last_message.sender_id,
          createdAt: last_message.created_at
        },
        unreadCount: unread_count,
        updatedAt: last_message.created_at
      }
    end
  end
end
