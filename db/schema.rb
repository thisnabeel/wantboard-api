# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_07_09_120000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "conversation_hides", id: false, force: :cascade do |t|
    t.datetime "hidden_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.uuid "offer_id", null: false
    t.uuid "user_id", null: false
    t.index ["offer_id", "user_id"], name: "index_conversation_hides_on_offer_id_and_user_id", unique: true
  end

  create_table "conversation_reads", id: false, force: :cascade do |t|
    t.datetime "last_read_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.uuid "offer_id", null: false
    t.uuid "user_id", null: false
    t.index ["offer_id", "user_id"], name: "index_conversation_reads_on_offer_id_and_user_id", unique: true
  end

  create_table "listings", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.decimal "budget", precision: 10, scale: 2
    t.string "category", null: false
    t.string "condition", default: "any", null: false
    t.datetime "created_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.text "description", null: false
    t.boolean "is_urgent", default: false, null: false
    t.string "location"
    t.string "status", default: "open", null: false
    t.string "title", null: false
    t.datetime "updated_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.uuid "user_id", null: false
    t.index ["category"], name: "index_listings_on_category"
    t.index ["status"], name: "index_listings_on_status"
    t.index ["user_id"], name: "index_listings_on_user_id"
  end

  create_table "messages", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.text "content", default: "", null: false
    t.datetime "created_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.text "image_base64"
    t.uuid "offer_id", null: false
    t.uuid "sender_id", null: false
    t.index ["offer_id"], name: "index_messages_on_offer_id"
    t.index ["sender_id"], name: "index_messages_on_sender_id"
  end

  create_table "offers", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.text "description"
    t.text "image_base64"
    t.uuid "listing_id", null: false
    t.string "match_type", null: false
    t.uuid "offerer_id", null: false
    t.decimal "price", precision: 10, scale: 2, null: false
    t.string "status", default: "pending", null: false
    t.index ["listing_id"], name: "index_offers_on_listing_id"
    t.index ["offerer_id"], name: "index_offers_on_offerer_id"
  end

  create_table "users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "avatar_url"
    t.text "bio"
    t.datetime "created_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.string "email", null: false
    t.string "location"
    t.string "name", null: false
    t.string "password_digest", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "conversation_hides", "offers", on_delete: :cascade
  add_foreign_key "conversation_hides", "users", on_delete: :cascade
  add_foreign_key "conversation_reads", "offers", on_delete: :cascade
  add_foreign_key "conversation_reads", "users", on_delete: :cascade
  add_foreign_key "listings", "users", on_delete: :cascade
  add_foreign_key "messages", "offers", on_delete: :cascade
  add_foreign_key "messages", "users", column: "sender_id", on_delete: :cascade
  add_foreign_key "offers", "listings", on_delete: :cascade
  add_foreign_key "offers", "users", column: "offerer_id", on_delete: :cascade
end
