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

ActiveRecord::Schema.define(version: 20150819174507) do

  create_table "customer_bank_accounts", force: true do |t|
    t.integer  "customer_id"
    t.string   "account_holder_name"
    t.string   "country_code"
    t.string   "currency"
    t.string   "bank_name"
    t.boolean  "enabled"
    t.string   "gc_id"
    t.datetime "gc_created_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "customer_bank_accounts", ["customer_id"], name: "index_customer_bank_accounts_on_customer_id"
  add_index "customer_bank_accounts", ["gc_id"], name: "index_customer_bank_accounts_on_gc_id"

  create_table "customers", force: true do |t|
    t.integer  "organisation_id"
    t.string   "address_line1"
    t.string   "address_line2"
    t.string   "address_line3"
    t.string   "city"
    t.string   "company_name"
    t.string   "country_code"
    t.string   "email"
    t.string   "given_name"
    t.string   "family_name"
    t.string   "postal_code"
    t.string   "region"
    t.string   "gc_id"
    t.datetime "gc_created_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "customers", ["gc_id"], name: "index_customers_on_gc_id"
  add_index "customers", ["organisation_id"], name: "index_customers_on_organisation_id"

  create_table "mandates", force: true do |t|
    t.integer  "customer_bank_account_id"
    t.string   "reference"
    t.string   "status"
    t.string   "scheme"
    t.date     "next_possible_charge_date"
    t.string   "gc_id"
    t.datetime "gc_created_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "mandates", ["customer_bank_account_id"], name: "index_mandates_on_customer_bank_account_id"
  add_index "mandates", ["gc_id"], name: "index_mandates_on_gc_id"

  create_table "organisation_updates", force: true do |t|
    t.integer  "organisation_id"
    t.string   "category"
    t.datetime "last_update"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "organisation_updates", ["organisation_id", "category"], name: "index_organisation_updates_on_organisation_id_and_category", unique: true
  add_index "organisation_updates", ["organisation_id"], name: "index_organisation_updates_on_organisation_id"

  create_table "organisations", force: true do |t|
    t.string   "access_token"
    t.string   "gc_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "organisations", ["gc_id"], name: "index_organisations_on_gc_id"

  create_table "payment_events", force: true do |t|
    t.integer  "payment_id"
    t.string   "action"
    t.string   "origin"
    t.string   "cause"
    t.text     "description"
    t.string   "scheme"
    t.string   "reason_code"
    t.string   "gc_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "payment_events", ["gc_id"], name: "index_payment_events_on_gc_id"
  add_index "payment_events", ["payment_id"], name: "index_payment_events_on_payment_id"

  create_table "payments", force: true do |t|
    t.integer  "mandate_id"
    t.date     "charge_date"
    t.integer  "amount"
    t.string   "description"
    t.string   "currency"
    t.string   "status"
    t.string   "reference"
    t.integer  "amount_refunded"
    t.string   "gc_id"
    t.datetime "gc_created_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "payments", ["gc_id"], name: "index_payments_on_gc_id"
  add_index "payments", ["mandate_id"], name: "index_payments_on_mandate_id"

end
