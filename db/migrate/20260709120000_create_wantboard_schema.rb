# frozen_string_literal: true

class CreateWantboardSchema < ActiveRecord::Migration[8.1]
  def change
    create_table :users, id: :uuid do |t|
      t.string :name, null: false
      t.string :email, null: false
      t.string :password_digest, null: false
      t.string :location
      t.text :bio
      t.string :avatar_url
      t.datetime :created_at, null: false, default: -> { "CURRENT_TIMESTAMP" }
    end
    add_index :users, :email, unique: true

    create_table :listings, id: :uuid do |t|
      t.references :user, null: false, foreign_key: { on_delete: :cascade }, type: :uuid
      t.string :title, null: false
      t.text :description, null: false
      t.string :category, null: false
      t.string :condition, null: false, default: "any"
      t.decimal :budget, precision: 10, scale: 2
      t.string :location
      t.boolean :is_urgent, null: false, default: false
      t.string :status, null: false, default: "open"
      t.datetime :created_at, null: false, default: -> { "CURRENT_TIMESTAMP" }
      t.datetime :updated_at, null: false, default: -> { "CURRENT_TIMESTAMP" }
    end
    add_index :listings, :status
    add_index :listings, :category

    create_table :offers, id: :uuid do |t|
      t.references :listing, null: false, foreign_key: { on_delete: :cascade }, type: :uuid
      t.references :offerer, null: false, foreign_key: { to_table: :users, on_delete: :cascade }, type: :uuid
      t.decimal :price, precision: 10, scale: 2, null: false
      t.string :match_type, null: false
      t.text :description
      t.text :image_base64
      t.string :status, null: false, default: "pending"
      t.datetime :created_at, null: false, default: -> { "CURRENT_TIMESTAMP" }
    end

    create_table :messages, id: :uuid do |t|
      t.references :offer, null: false, foreign_key: { on_delete: :cascade }, type: :uuid
      t.references :sender, null: false, foreign_key: { to_table: :users, on_delete: :cascade }, type: :uuid
      t.text :content, null: false, default: ""
      t.text :image_base64
      t.datetime :created_at, null: false, default: -> { "CURRENT_TIMESTAMP" }
    end

    create_table :conversation_reads, id: false do |t|
      t.uuid :offer_id, null: false
      t.uuid :user_id, null: false
      t.datetime :last_read_at, null: false, default: -> { "CURRENT_TIMESTAMP" }
    end
    add_foreign_key :conversation_reads, :offers, on_delete: :cascade
    add_foreign_key :conversation_reads, :users, on_delete: :cascade
    add_index :conversation_reads, [:offer_id, :user_id], unique: true

    create_table :conversation_hides, id: false do |t|
      t.uuid :offer_id, null: false
      t.uuid :user_id, null: false
      t.datetime :hidden_at, null: false, default: -> { "CURRENT_TIMESTAMP" }
    end
    add_foreign_key :conversation_hides, :offers, on_delete: :cascade
    add_foreign_key :conversation_hides, :users, on_delete: :cascade
    add_index :conversation_hides, [:offer_id, :user_id], unique: true
  end
end
