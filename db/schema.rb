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

ActiveRecord::Schema.define(version: 20160610172649) do

  create_table "bills", force: :cascade do |t|
    t.string   "txn_type",     limit: 255
    t.datetime "txn_date"
    t.string   "klass",        limit: 255
    t.string   "dept",         limit: 255
    t.string   "account_name", limit: 255
    t.string   "vendor_name",  limit: 255
    t.string   "desc",         limit: 255
    t.decimal  "amount",                   precision: 10
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
  end

  create_table "budgets", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.integer  "parent_id",  limit: 4
    t.integer  "order_id",   limit: 4
    t.boolean  "is_account"
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "journal_entries", force: :cascade do |t|
    t.string   "txn_type",     limit: 255
    t.datetime "txn_date"
    t.string   "klass",        limit: 255
    t.string   "dept",         limit: 255
    t.string   "account_name", limit: 255
    t.string   "vendor_name",  limit: 255
    t.string   "desc",         limit: 255
    t.decimal  "amount",                   precision: 10
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
  end

  create_table "profit_losses", force: :cascade do |t|
    t.string   "txn_type",   limit: 255
    t.integer  "account_id", limit: 4
    t.date     "txn_date"
    t.string   "class_name", limit: 255
    t.string   "dept_name",  limit: 255
    t.string   "vendor",     limit: 255
    t.string   "memo",       limit: 255
    t.float    "amount",     limit: 24
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "tokens", force: :cascade do |t|
    t.string   "access_token",     limit: 255
    t.string   "access_secret",    limit: 255
    t.string   "company_id",       limit: 255
    t.datetime "token_expires_at"
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
  end

  create_table "transactions", primary_key: "txn_id", force: :cascade do |t|
    t.string   "txn_type",     limit: 255
    t.datetime "txn_date"
    t.string   "klass",        limit: 255
    t.string   "dept",         limit: 255
    t.string   "account_name", limit: 255
    t.string   "vendor_name",  limit: 255
    t.string   "desc",         limit: 255
    t.decimal  "amount",                   precision: 10
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
  end

end
