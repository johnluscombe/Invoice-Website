# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20171219024630) do

  create_table "blacklist_ip_addresses", force: :cascade do |t|
    t.string "begin_ip"
    t.string "end_ip"
  end

  create_table "invoices", force: :cascade do |t|
    t.date     "start_date"
    t.date     "end_date"
    t.string   "status"
    t.integer  "user_id"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.float    "hours"
    t.float    "net_pay"
    t.boolean  "status_override"
    t.float    "rate"
    t.integer  "check_no"
    t.date     "transfer_date"
  end

  add_index "invoices", ["user_id"], name: "index_invoices_on_user_id"

  create_table "payments", force: :cascade do |t|
    t.date     "date"
    t.string   "description"
    t.float    "hours"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.integer  "invoice_id"
    t.float    "daily_rate"
  end

  add_index "payments", ["invoice_id"], name: "index_payments_on_invoice_id"

  create_table "users", force: :cascade do |t|
    t.string   "name"
    t.string   "password_digest"
    t.string   "email"
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.float    "rate"
    t.string   "fullname"
    t.boolean  "first_time",      default: true
    t.integer  "profile",         default: 1
  end

  create_table "whitelist_ip_addresses", force: :cascade do |t|
    t.string "begin_ip"
    t.string "end_ip"
  end

end
