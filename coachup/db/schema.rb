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

ActiveRecord::Schema.define(version: 20151120093009) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "courses", force: :cascade do |t|
    t.string   "title"
    t.string   "description"
    t.integer  "price"
    t.integer  "coach_id"
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.string   "sport"
    t.integer  "max_participants", default: 1
    t.integer  "location_id",                  null: false
    t.string   "schedule"
    t.datetime "starts_at",                    null: false
    t.datetime "ends_at",                      null: false
    t.time     "duration",                     null: false
  end

  add_index "courses", ["coach_id"], name: "index_courses_on_coach_id", using: :btree
  add_index "courses", ["location_id"], name: "index_courses_on_location_id", using: :btree

  create_table "locations", force: :cascade do |t|
    t.float    "latitude"
    t.float    "longitude"
    t.string   "address"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "subscriptions", force: :cascade do |t|
    t.integer  "course_id"
    t.integer  "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "subscriptions", ["course_id"], name: "index_subscriptions_on_course_id", using: :btree
  add_index "subscriptions", ["user_id"], name: "index_subscriptions_on_user_id", using: :btree

  create_table "training_sessions", force: :cascade do |t|
    t.string   "description"
    t.datetime "starts_at"
    t.datetime "ends_at"
    t.integer  "course_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.string   "schedule"
  end

  add_index "training_sessions", ["course_id"], name: "index_training_sessions_on_course_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "email",         default: "", null: false
    t.string   "username"
    t.string   "address"
    t.string   "country"
    t.string   "phone"
    t.date     "date_of_birth"
    t.string   "education"
    t.text     "bio"
    t.string   "aboutme"
    t.string   "avatar"
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  add_index "users", ["username"], name: "index_users_on_username", unique: true, using: :btree

  create_table "votes", force: :cascade do |t|
    t.integer  "votable_id"
    t.string   "votable_type"
    t.integer  "voter_id"
    t.string   "voter_type"
    t.boolean  "vote_flag"
    t.string   "vote_scope"
    t.integer  "vote_weight"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "votes", ["votable_id", "votable_type", "vote_scope"], name: "index_votes_on_votable_id_and_votable_type_and_vote_scope", using: :btree
  add_index "votes", ["voter_id", "voter_type", "vote_scope"], name: "index_votes_on_voter_id_and_voter_type_and_vote_scope", using: :btree

  add_foreign_key "courses", "locations"
  add_foreign_key "courses", "users", column: "coach_id"
  add_foreign_key "subscriptions", "courses"
  add_foreign_key "subscriptions", "users"
end
