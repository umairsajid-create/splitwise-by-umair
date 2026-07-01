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

ActiveRecord::Schema[8.1].define(version: 2026_07_01_123031) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "categories", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "icon"
    t.string "name"
    t.string "section"
    t.datetime "updated_at", null: false
  end

  create_table "default_splits", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "group_id", null: false
    t.string "name", null: false
    t.jsonb "split_config", default: {}, null: false
    t.integer "split_type", default: 0, null: false, comment: "0:equal, 1:exact, 2:percentage, 3:adjustment"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["group_id"], name: "index_default_splits_on_group_id"
    t.index ["user_id", "group_id"], name: "index_default_splits_on_user_id_and_group_id"
    t.index ["user_id"], name: "index_default_splits_on_user_id"
  end

  create_table "expense_splits", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "expense_id", null: false
    t.integer "owed_amount_cents", default: 0, null: false
    t.integer "paid_amount_cents", default: 0, null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["expense_id", "user_id"], name: "index_expense_splits_on_expense_id_and_user_id", unique: true
    t.index ["expense_id"], name: "index_expense_splits_on_expense_id"
    t.index ["user_id"], name: "index_expense_splits_on_user_id"
  end

  create_table "expenses", force: :cascade do |t|
    t.integer "category_id"
    t.datetime "created_at", null: false
    t.bigint "created_by_id", null: false
    t.string "currency", default: "PKR", null: false
    t.date "expense_date", null: false
    t.bigint "group_id", null: false
    t.boolean "is_multi_payer", default: false, null: false
    t.text "note"
    t.bigint "paid_by_id"
    t.integer "payer_ids", default: [], array: true
    t.integer "record_type", default: 0, null: false, comment: "0:expense, 1:settlement"
    t.integer "split_type", default: 0, null: false, comment: "0:equal, 1:exact, 2:percentage, 3:adjustment"
    t.integer "status", default: 0, null: false, comment: "0:active, 1:deleted, 2:updated"
    t.string "title", null: false
    t.integer "total_amount_cents", null: false
    t.datetime "updated_at", null: false
    t.index ["created_by_id"], name: "index_expenses_on_created_by_id"
    t.index ["expense_date"], name: "index_expenses_on_expense_date"
    t.index ["group_id"], name: "index_expenses_on_group_id"
    t.index ["paid_by_id"], name: "index_expenses_on_paid_by_id"
    t.index ["payer_ids"], name: "index_expenses_on_payer_ids", using: :gin
    t.index ["record_type"], name: "index_expenses_on_record_type"
    t.index ["status"], name: "index_expenses_on_status"
  end

  create_table "group_invitations", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.datetime "expires_at", null: false
    t.bigint "group_id", null: false
    t.bigint "invited_by_id", null: false
    t.integer "status", default: 0, null: false, comment: "0:pending, 1:accepted, 2:declined, 3:expired"
    t.string "token", null: false
    t.datetime "updated_at", null: false
    t.index ["group_id", "email"], name: "index_group_invitations_on_group_id_and_email", unique: true
    t.index ["group_id"], name: "index_group_invitations_on_group_id"
    t.index ["invited_by_id"], name: "index_group_invitations_on_invited_by_id"
    t.index ["status"], name: "index_group_invitations_on_status"
    t.index ["token"], name: "index_group_invitations_on_token", unique: true
  end

  create_table "group_members", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "group_id", null: false
    t.bigint "invited_by_id"
    t.datetime "joined_at", null: false
    t.integer "role", default: 0, null: false, comment: "0:member, 1:admin"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["group_id", "user_id"], name: "index_group_members_on_group_id_and_user_id", unique: true
    t.index ["group_id"], name: "index_group_members_on_group_id"
    t.index ["invited_by_id"], name: "index_group_members_on_invited_by_id"
    t.index ["user_id"], name: "index_group_members_on_user_id"
  end

  create_table "groups", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "creator_id", null: false
    t.integer "group_type", default: 0, null: false, comment: "0:home, 1:trip, 2:couple, 3:other"
    t.boolean "is_active", default: true, null: false
    t.string "name", null: false
    t.boolean "simplify_debts", default: false, null: false
    t.datetime "updated_at", null: false
    t.index ["creator_id"], name: "index_groups_on_creator_id"
    t.index ["is_active"], name: "index_groups_on_is_active"
  end

  create_table "notification_recipients", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "notification_id", null: false
    t.datetime "read_at"
    t.bigint "recipient_id", null: false
    t.datetime "updated_at", null: false
    t.index ["notification_id", "recipient_id"], name: "idx_notif_recipients_on_notif_and_recipient", unique: true
    t.index ["notification_id"], name: "index_notification_recipients_on_notification_id"
    t.index ["recipient_id", "read_at"], name: "idx_notif_recipients_on_recipient_and_read"
    t.index ["recipient_id"], name: "index_notification_recipients_on_recipient_id"
  end

  create_table "notifications", force: :cascade do |t|
    t.bigint "actor_id", null: false
    t.text "body"
    t.datetime "created_at", null: false
    t.bigint "notifiable_id", null: false
    t.string "notifiable_type", null: false
    t.integer "notification_type", null: false, comment: "0:expense_added, 1:expense_updated, etc."
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.index ["actor_id"], name: "index_notifications_on_actor_id"
    t.index ["created_at"], name: "index_notifications_on_created_at"
    t.index ["notifiable_type", "notifiable_id"], name: "index_notifications_on_notifiable_type_and_notifiable_id"
    t.index ["notification_type"], name: "index_notifications_on_notification_type"
  end

  create_table "subscriptions", force: :cascade do |t|
    t.integer "amount_cents", null: false
    t.datetime "cancelled_at"
    t.datetime "created_at", null: false
    t.string "currency", default: "PKR", null: false
    t.datetime "ends_at", null: false
    t.integer "payment_method", comment: "0:credit_card, 1:debit_card, 2:bank_transfer, 3:wallet"
    t.integer "plan", default: 0, null: false, comment: "0:monthly, 1:yearly"
    t.datetime "starts_at", null: false
    t.integer "status", default: 0, null: false, comment: "0:active, 1:cancelled, 2:expired, 3:past_due"
    t.string "transaction_id"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["ends_at"], name: "index_subscriptions_on_ends_at"
    t.index ["status"], name: "index_subscriptions_on_status"
    t.index ["user_id"], name: "index_subscriptions_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.integer "balance_cents", default: 0, null: false
    t.datetime "blocked_at"
    t.datetime "created_at", null: false
    t.integer "daily_expense_limit", default: 5, null: false
    t.integer "daily_settlement_limit", default: 3, null: false
    t.string "default_currency", default: "PKR", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.datetime "last_login_at"
    t.string "phone_number"
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.integer "role", default: 0, null: false, comment: "0:simple, 1:premium, 2:admin"
    t.datetime "updated_at", null: false
    t.string "username", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["phone_number"], name: "index_users_on_phone_number"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["role"], name: "index_users_on_role"
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "default_splits", "groups"
  add_foreign_key "default_splits", "users"
  add_foreign_key "expense_splits", "expenses"
  add_foreign_key "expense_splits", "users"
  add_foreign_key "expenses", "groups"
  add_foreign_key "expenses", "users", column: "created_by_id"
  add_foreign_key "group_invitations", "groups"
  add_foreign_key "group_invitations", "users", column: "invited_by_id"
  add_foreign_key "group_members", "groups"
  add_foreign_key "group_members", "users"
  add_foreign_key "group_members", "users", column: "invited_by_id"
  add_foreign_key "groups", "users", column: "creator_id"
  add_foreign_key "notification_recipients", "notifications"
  add_foreign_key "notification_recipients", "users", column: "recipient_id"
  add_foreign_key "notifications", "users", column: "actor_id"
  add_foreign_key "subscriptions", "users"
end
