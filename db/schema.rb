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

ActiveRecord::Schema.define(version: 20130807121937) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "hstore"

  create_table "contacts", force: true do |t|
    t.integer  "user_id"
    t.string   "name"
    t.hstore   "data"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.hstore   "pending_data"
    t.hstore   "original_data"
  end

  add_index "contacts", ["data"], name: "contacts_data", using: :gist
  add_index "contacts", ["user_id"], name: "index_contacts_on_user_id", using: :btree

  create_table "fields", force: true do |t|
    t.integer  "user_id"
    t.string   "title"
    t.string   "permalink"
    t.string   "data_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "fields", ["user_id"], name: "index_fields_on_user_id", using: :btree

  create_table "followups", force: true do |t|
    t.integer  "user_id"
    t.text     "criteria"
    t.text     "description"
    t.integer  "field_id"
    t.datetime "starting_at"
    t.integer  "offset",      default: 0
    t.integer  "recurrence",  default: 0
    t.boolean  "recurring",   default: true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "followups", ["field_id"], name: "index_followups_on_field_id", using: :btree
  add_index "followups", ["user_id"], name: "index_followups_on_user_id", using: :btree

  create_table "tasks", force: true do |t|
    t.integer  "followup_id"
    t.integer  "contact_id"
    t.datetime "date"
    t.text     "content"
    t.boolean  "complete",    default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "tasks", ["contact_id"], name: "index_tasks_on_contact_id", using: :btree
  add_index "tasks", ["followup_id"], name: "index_tasks_on_followup_id", using: :btree

  create_table "users", force: true do |t|
    t.string   "email",                  default: "",  null: false
    t.string   "encrypted_password",     default: "",  null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "file_file_name"
    t.string   "file_content_type"
    t.integer  "file_file_size"
    t.datetime "file_updated_at"
    t.text     "blob"
    t.string   "name"
    t.integer  "import_progress",        default: 100
    t.integer  "contacts_count",         default: 0
    t.integer  "step",                   default: 1
    t.string   "time_zone"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

end
