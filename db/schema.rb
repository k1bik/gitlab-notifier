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

ActiveRecord::Schema[8.0].define(version: 2025_10_05_123217) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "estimation_items", force: :cascade do |t|
    t.string "reference_url", null: false
    t.boolean "results_sent", default: false, null: false, comment: "Whether the results have been sent to the users"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "estimations", force: :cascade do |t|
    t.bigint "user_mapping_id", null: false
    t.bigint "estimation_item_id", null: false
    t.string "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["estimation_item_id"], name: "index_estimations_on_estimation_item_id"
    t.index ["user_mapping_id", "estimation_item_id"], name: "index_estimations_on_user_mapping_id_and_estimation_item_id", unique: true
    t.index ["user_mapping_id"], name: "index_estimations_on_user_mapping_id"
  end

  create_table "settings", force: :cascade do |t|
    t.string "var", null: false
    t.text "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["var"], name: "index_settings_on_var", unique: true
  end

  create_table "user_mappings", force: :cascade do |t|
    t.string "email", null: false
    t.string "slack_user_id", null: false
    t.string "slack_channel_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "gitlab_id", null: false
    t.string "gitlab_username", null: false
  end

  add_foreign_key "estimations", "estimation_items"
  add_foreign_key "estimations", "user_mappings"
end
