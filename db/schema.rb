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

ActiveRecord::Schema[8.1].define(version: 2025_11_26_173136) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "rocket_messages", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.jsonb "message"
    t.integer "number"
    t.bigint "rocket_id", null: false
    t.datetime "time"
    t.string "type"
    t.datetime "updated_at", null: false
    t.index ["rocket_id", "number"], name: "index_rocket_messages_on_rocket_id_and_number", unique: true
    t.index ["rocket_id"], name: "index_rocket_messages_on_rocket_id"
  end

  create_table "rockets", force: :cascade do |t|
    t.string "accident"
    t.datetime "created_at", null: false
    t.datetime "last_processed_message_at"
    t.integer "last_processed_message_number"
    t.string "mission"
    t.string "rocket_type"
    t.integer "speed"
    t.string "status"
    t.datetime "updated_at", null: false
    t.uuid "uuid"
    t.index ["uuid"], name: "index_rockets_on_uuid", unique: true
  end

  add_foreign_key "rocket_messages", "rockets"
end
