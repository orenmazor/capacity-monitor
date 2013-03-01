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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130228204822) do

  create_table "agents", :force => true do |t|
    t.integer  "newrelic_id"
    t.string   "hostname"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.string   "role"
  end

  create_table "metrics", :force => true do |t|
    t.string   "name"
    t.string   "type"
    t.integer  "maximum"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.integer  "agent_id"
    t.string   "field"
    t.float    "slope"
    t.float    "offset"
  end

  create_table "runs", :force => true do |t|
    t.datetime "begin"
    t.datetime "end"
    t.text     "failures"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "samples", :force => true do |t|
    t.integer  "metric_id"
    t.decimal  "value",         :precision => 14, :scale => 4
    t.datetime "created_at",                                   :null => false
    t.datetime "updated_at",                                   :null => false
    t.datetime "fetched_at"
    t.string   "type"
    t.integer  "run_id"
    t.integer  "bucket_number"
  end

end
