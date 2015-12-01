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

ActiveRecord::Schema.define(version: 20151105192340) do

  create_table "admins", force: true do |t|
    t.string   "email"
    t.string   "password_digest"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "admins", ["email"], name: "index_admins_on_email"

  create_table "client_sources", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "display_name"
  end

  add_index "client_sources", ["name"], name: "index_client_sources_on_name"

  create_table "clients", force: true do |t|
    t.integer  "organisation_id"
    t.string   "fname"
    t.string   "lname"
    t.string   "company_name"
    t.string   "email"
    t.integer  "client_source_id"
    t.string   "source_client_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "token"
    t.string   "customer_gc_id"
    t.datetime "source_created_at"
    t.string   "locale"
    t.text     "mandate_request_description"
    t.datetime "mandate_request_date"
  end

  add_index "clients", ["client_source_id"], name: "index_clients_on_client_source_id"
  add_index "clients", ["customer_gc_id"], name: "index_clients_on_customer_gc_id"
  add_index "clients", ["email"], name: "index_clients_on_email"
  add_index "clients", ["organisation_id"], name: "index_clients_on_organisation_id"
  add_index "clients", ["source_client_id"], name: "index_clients_on_source_client_id"
  add_index "clients", ["token"], name: "index_clients_on_token"

  create_table "creditors", force: true do |t|
    t.integer  "organisation_id"
    t.string   "name"
    t.string   "address_line1"
    t.string   "address_line2"
    t.string   "address_line3"
    t.string   "city"
    t.string   "region"
    t.string   "postal_code"
    t.string   "country_code"
    t.string   "gc_id"
    t.datetime "gc_created_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "creditors", ["gc_id"], name: "index_creditors_on_gc_id"
  add_index "creditors", ["organisation_id"], name: "index_creditors_on_organisation_id"

  create_table "customer_bank_accounts", force: true do |t|
    t.string   "customer_id"
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
    t.integer  "client_id"
  end

  add_index "customers", ["client_id"], name: "index_customers_on_client_id"
  add_index "customers", ["gc_id"], name: "index_customers_on_gc_id"

  create_table "events", force: true do |t|
    t.string   "payment_id"
    t.string   "action"
    t.string   "origin"
    t.string   "cause"
    t.text     "description"
    t.string   "scheme"
    t.string   "reason_code"
    t.string   "gc_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "gc_created_at"
    t.string   "resource_type"
    t.string   "mandate_id"
    t.string   "payout_id"
    t.string   "refund_id"
    t.string   "subscription_id"
    t.string   "new_customer_bank_account_id"
    t.string   "previous_customer_bank_account_id"
    t.string   "parent_event_id"
  end

  add_index "events", ["action"], name: "index_events_on_action"
  add_index "events", ["gc_id"], name: "index_events_on_gc_id"
  add_index "events", ["mandate_id"], name: "index_events_on_mandate_id"
  add_index "events", ["new_customer_bank_account_id"], name: "index_events_on_new_customer_bank_account_id"
  add_index "events", ["parent_event_id"], name: "index_events_on_parent_event_id"
  add_index "events", ["payment_id"], name: "index_events_on_payment_id"
  add_index "events", ["payout_id"], name: "index_events_on_payout_id"
  add_index "events", ["previous_customer_bank_account_id"], name: "index_events_on_previous_customer_bank_account_id"
  add_index "events", ["refund_id"], name: "index_events_on_refund_id"
  add_index "events", ["resource_type"], name: "index_events_on_resource_type"
  add_index "events", ["subscription_id"], name: "index_events_on_subscription_id"

  create_table "fees", force: true do |t|
    t.string   "event_id"
    t.integer  "amount"
    t.string   "currency"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "fees", ["event_id"], name: "index_fees_on_event_id"

  create_table "mandates", force: true do |t|
    t.string   "customer_bank_account_id"
    t.string   "reference"
    t.string   "status"
    t.string   "scheme"
    t.date     "next_possible_charge_date"
    t.string   "gc_id"
    t.datetime "gc_created_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "creditor_id"
  end

  add_index "mandates", ["creditor_id"], name: "index_mandates_on_creditor_id"
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
    t.string   "fname"
    t.string   "lname"
    t.string   "email"
    t.string   "company_name"
    t.datetime "last_login"
    t.string   "country"
    t.string   "locale"
  end

  add_index "organisations", ["gc_id"], name: "index_organisations_on_gc_id"

  create_table "payments", force: true do |t|
    t.string   "mandate_id"
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

  create_table "payouts", force: true do |t|
    t.string   "creditor_id"
    t.integer  "amount"
    t.string   "currency"
    t.string   "reference"
    t.string   "status"
    t.string   "gc_id"
    t.datetime "gc_created_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "payouts", ["creditor_id"], name: "index_payouts_on_creditor_id"
  add_index "payouts", ["gc_id"], name: "index_payouts_on_gc_id"

  create_table "refunds", force: true do |t|
    t.string   "payment_id"
    t.integer  "amount"
    t.string   "currency"
    t.string   "gc_id"
    t.datetime "gc_created_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "refunds", ["gc_id"], name: "index_refunds_on_gc_id"
  add_index "refunds", ["payment_id"], name: "index_refunds_on_payment_id"

  create_table "revenues", force: true do |t|
    t.integer  "organisation_id"
    t.string   "category"
    t.string   "reference"
    t.integer  "amount"
    t.string   "currency"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "revenues", ["category"], name: "index_revenues_on_category"
  add_index "revenues", ["organisation_id"], name: "index_revenues_on_organisation_id"
  add_index "revenues", ["reference"], name: "index_revenues_on_reference"

  create_table "subscriptions", force: true do |t|
    t.string   "mandate_id"
    t.integer  "amount"
    t.string   "currency"
    t.string   "status"
    t.string   "name"
    t.datetime "start_date"
    t.datetime "end_date"
    t.integer  "interval"
    t.string   "interval_unit"
    t.integer  "day_of_month"
    t.string   "month"
    t.string   "payment_reference"
    t.string   "gc_id"
    t.datetime "gc_created_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "subscriptions", ["gc_id"], name: "index_subscriptions_on_gc_id"
  add_index "subscriptions", ["mandate_id"], name: "index_subscriptions_on_mandate_id"

end
