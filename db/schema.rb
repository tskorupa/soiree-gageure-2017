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

ActiveRecord::Schema.define(version: 20161105153125) do

  create_table "guests", force: :cascade do |t|
    t.string   "full_name",  null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["full_name"], name: "index_guests_on_full_name"
  end

  create_table "lotteries", force: :cascade do |t|
    t.date     "event_date",                                 null: false
    t.decimal  "meal_voucher_price", precision: 5, scale: 2
    t.decimal  "ticket_price",       precision: 5, scale: 2
    t.datetime "created_at",                                 null: false
    t.datetime "updated_at",                                 null: false
    t.index ["event_date"], name: "index_lotteries_on_event_date"
  end

  create_table "prizes", force: :cascade do |t|
    t.integer  "lottery_id",                         null: false
    t.integer  "draw_order",                         null: false
    t.decimal  "amount",     precision: 5, scale: 2, null: false
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
    t.index ["draw_order"], name: "index_prizes_on_draw_order"
    t.index ["lottery_id"], name: "index_prizes_on_lottery_id"
  end

  create_table "sellers", force: :cascade do |t|
    t.string   "full_name",  null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["full_name"], name: "index_sellers_on_full_name"
  end

  create_table "sponsors", force: :cascade do |t|
    t.string   "full_name",  null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["full_name"], name: "index_sponsors_on_full_name"
  end

  create_table "tables", force: :cascade do |t|
    t.integer  "lottery_id", null: false
    t.integer  "number",     null: false
    t.integer  "capacity",   null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["lottery_id", "number"], name: "index_tables_on_lottery_id_and_number", unique: true
    t.index ["lottery_id"], name: "index_tables_on_lottery_id"
    t.index ["number"], name: "index_tables_on_number"
  end

  create_table "tickets", force: :cascade do |t|
    t.integer  "lottery_id", null: false
    t.integer  "seller_id",  null: false
    t.integer  "guest_id"
    t.integer  "number",     null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "sponsor_id"
    t.index ["guest_id"], name: "index_tickets_on_guest_id"
    t.index ["lottery_id", "number"], name: "index_tickets_on_lottery_id_and_number", unique: true
    t.index ["lottery_id"], name: "index_tickets_on_lottery_id"
    t.index ["number"], name: "index_tickets_on_number"
    t.index ["seller_id"], name: "index_tickets_on_seller_id"
    t.index ["sponsor_id"], name: "index_tickets_on_sponsor_id"
  end

end
