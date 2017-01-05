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

ActiveRecord::Schema.define(version: 20170105150758) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "pg_trgm"

  create_table "ar_internal_metadata", primary_key: "key", id: :string, force: :cascade do |t|
    t.string   "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "guests", force: :cascade do |t|
    t.string   "full_name",  null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index "to_tsvector('english'::regconfig, 'full_name'::text)", name: "full_text_en_on_guests", using: :gin
    t.index ["full_name"], name: "index_guests_on_full_name", using: :btree
  end

  create_table "lotteries", force: :cascade do |t|
    t.date     "event_date",                                 null: false
    t.decimal  "meal_voucher_price", precision: 6, scale: 2
    t.decimal  "ticket_price",       precision: 6, scale: 2
    t.datetime "created_at",                                 null: false
    t.datetime "updated_at",                                 null: false
    t.index ["event_date"], name: "index_lotteries_on_event_date", order: {"event_date"=>:desc}, using: :btree
  end

  create_table "prizes", force: :cascade do |t|
    t.integer  "lottery_id",                         null: false
    t.integer  "draw_order",                         null: false
    t.decimal  "amount",     precision: 6, scale: 2, null: false
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
    t.index ["draw_order"], name: "index_prizes_on_draw_order", using: :btree
    t.index ["lottery_id", "draw_order"], name: "index_prizes_on_lottery_id_and_draw_order", unique: true, using: :btree
    t.index ["lottery_id"], name: "index_prizes_on_lottery_id", using: :btree
  end

  create_table "sellers", force: :cascade do |t|
    t.string   "full_name",  null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index "to_tsvector('english'::regconfig, 'full_name'::text)", name: "full_text_en_on_sellers", using: :gin
    t.index ["full_name"], name: "index_sellers_on_full_name", using: :btree
  end

  create_table "sponsors", force: :cascade do |t|
    t.string   "full_name",  null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index "to_tsvector('english'::regconfig, 'full_name'::text)", name: "full_text_en_on_sponsors", using: :gin
    t.index ["full_name"], name: "index_sponsors_on_full_name", using: :btree
  end

  create_table "tables", force: :cascade do |t|
    t.integer  "lottery_id", null: false
    t.integer  "number",     null: false
    t.integer  "capacity",   null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["lottery_id", "number"], name: "index_tables_on_lottery_id_and_number", unique: true, using: :btree
    t.index ["lottery_id"], name: "index_tables_on_lottery_id", using: :btree
    t.index ["number"], name: "index_tables_on_number", using: :btree
  end

  create_table "tickets", force: :cascade do |t|
    t.integer  "lottery_id",                  null: false
    t.integer  "seller_id"
    t.integer  "guest_id"
    t.integer  "number",                      null: false
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.integer  "sponsor_id"
    t.string   "state",                       null: false
    t.string   "ticket_type",                 null: false
    t.boolean  "registered",  default: false, null: false
    t.index ["guest_id"], name: "index_tickets_on_guest_id", using: :btree
    t.index ["lottery_id", "number"], name: "index_tickets_on_lottery_id_and_number", unique: true, using: :btree
    t.index ["lottery_id", "registered"], name: "index_tickets_on_lottery_id_and_registered", using: :btree
    t.index ["lottery_id"], name: "index_tickets_on_lottery_id", using: :btree
    t.index ["number"], name: "index_tickets_on_number", using: :btree
    t.index ["seller_id"], name: "index_tickets_on_seller_id", using: :btree
    t.index ["sponsor_id"], name: "index_tickets_on_sponsor_id", using: :btree
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",              null: false
    t.string   "encrypted_password", null: false
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
    t.index ["email"], name: "index_users_on_email", unique: true, using: :btree
  end


  create_view :ticket_searches,  sql_definition: <<-SQL
      SELECT tickets.id AS ticket_id,
      ((''::text || tickets.number) || ''::text) AS term
     FROM tickets
  UNION
   SELECT tickets.id AS ticket_id,
      sellers.full_name AS term
     FROM (tickets
       JOIN sellers ON ((tickets.seller_id = sellers.id)))
  UNION
   SELECT tickets.id AS ticket_id,
      guests.full_name AS term
     FROM (tickets
       JOIN guests ON ((tickets.guest_id = guests.id)))
  UNION
   SELECT tickets.id AS ticket_id,
      sponsors.full_name AS term
     FROM (tickets
       JOIN sponsors ON ((tickets.sponsor_id = sponsors.id)));
  SQL

end
