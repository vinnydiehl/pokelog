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

ActiveRecord::Schema[7.0].define(version: 2022_12_21_190321) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "hstore"
  enable_extension "plpgsql"

  # Custom types defined in this database.
  # Note that some types may not work with other database engines. Be careful if changing database.
  create_enum "nature", ["hardy", "lonely", "brave", "adamant", "naughty", "bold", "docile", "relaxed", "impish", "lax", "timid", "hasty", "serious", "jolly", "naive", "modest", "mild", "quiet", "bashful", "rash", "calm", "gentle", "sassy", "careful", "quirky"]

  create_table "kills", id: false, force: :cascade do |t|
    t.bigint "trainees_id"
    t.string "species_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["trainees_id"], name: "index_kills_on_trainees_id"
  end

  create_table "trainees", force: :cascade do |t|
    t.bigint "user_id"
    t.integer "team_id"
    t.string "species_id"
    t.string "nickname"
    t.integer "level"
    t.boolean "pokerus", default: false
    t.enum "nature", enum_type: "nature"
    t.integer "hp_ev", default: 0
    t.integer "atk_ev", default: 0
    t.integer "def_ev", default: 0
    t.integer "spa_ev", default: 0
    t.integer "spd_ev", default: 0
    t.integer "spe_ev", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_trainees_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email"
    t.string "username"
    t.string "google_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
