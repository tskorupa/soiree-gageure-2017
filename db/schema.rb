# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20170602214354) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "pg_trgm"

  create_table "guests", id: :serial, force: :cascade do |t|
    t.string "full_name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index "to_tsvector('english'::regconfig, 'full_name'::text)", name: "full_text_en_on_guests", using: :gin
    t.index ["full_name"], name: "index_guests_on_full_name"
  end

  create_table "lotteries", id: :serial, force: :cascade do |t|
    t.date "event_date", null: false
    t.decimal "meal_voucher_price", precision: 6, scale: 2
    t.decimal "ticket_price", precision: 6, scale: 2
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "locked", default: false, null: false
    t.index ["event_date"], name: "index_lotteries_on_event_date", order: { event_date: :desc }
    t.index ["locked"], name: "index_lotteries_on_locked"
  end

  create_table "prizes", id: :serial, force: :cascade do |t|
    t.integer "lottery_id", null: false
    t.integer "draw_order", null: false
    t.decimal "amount", precision: 6, scale: 2, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "nth_before_last"
    t.integer "ticket_id"
    t.index ["draw_order"], name: "index_prizes_on_draw_order"
    t.index ["lottery_id", "draw_order"], name: "index_prizes_on_lottery_id_and_draw_order", unique: true
    t.index ["lottery_id", "nth_before_last"], name: "index_prizes_on_lottery_id_and_nth_before_last", unique: true
    t.index ["lottery_id"], name: "index_prizes_on_lottery_id"
    t.index ["ticket_id"], name: "index_prizes_on_ticket_id", unique: true
  end

  create_table "sellers", id: :serial, force: :cascade do |t|
    t.string "full_name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index "to_tsvector('english'::regconfig, 'full_name'::text)", name: "full_text_en_on_sellers", using: :gin
    t.index ["full_name"], name: "index_sellers_on_full_name"
  end

  create_table "sponsors", id: :serial, force: :cascade do |t|
    t.string "full_name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index "to_tsvector('english'::regconfig, 'full_name'::text)", name: "full_text_en_on_sponsors", using: :gin
    t.index ["full_name"], name: "index_sponsors_on_full_name"
  end

  create_table "tables", id: :serial, force: :cascade do |t|
    t.integer "lottery_id", null: false
    t.integer "number", null: false
    t.integer "capacity", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "tickets_count", default: 0, null: false
    t.index ["lottery_id", "number"], name: "index_tables_on_lottery_id_and_number", unique: true
    t.index ["lottery_id"], name: "index_tables_on_lottery_id"
    t.index ["number"], name: "index_tables_on_number"
  end

  create_table "tickets", id: :serial, force: :cascade do |t|
    t.integer "lottery_id", null: false
    t.integer "seller_id"
    t.integer "guest_id"
    t.integer "number", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "sponsor_id"
    t.string "state", null: false
    t.string "ticket_type", null: false
    t.boolean "registered", default: false, null: false
    t.integer "table_id"
    t.boolean "dropped_off", default: false, null: false
    t.integer "drawn_position"
    t.index ["guest_id"], name: "index_tickets_on_guest_id"
    t.index ["lottery_id", "drawn_position"], name: "index_tickets_on_lottery_id_and_drawn_position", unique: true
    t.index ["lottery_id", "number"], name: "index_tickets_on_lottery_id_and_number", unique: true
    t.index ["lottery_id"], name: "index_tickets_on_lottery_id"
    t.index ["number"], name: "index_tickets_on_number"
    t.index ["seller_id"], name: "index_tickets_on_seller_id"
    t.index ["sponsor_id"], name: "index_tickets_on_sponsor_id"
    t.index ["table_id"], name: "index_tickets_on_table_id"
  end

  create_table "users", id: :serial, force: :cascade do |t|
    t.string "email", null: false
    t.string "encrypted_password", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

end
