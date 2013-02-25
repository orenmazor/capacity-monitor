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

<<<<<<< HEAD
ActiveRecord::Schema.define(:version => 20130225012823) do
=======
ActiveRecord::Schema.define(:version => 20130224230538) do
>>>>>>> 9fdd82ddc5bada3e27d2f7b1b0d249a1023516a9

  create_table "agents", :force => true do |t|
    t.string   "agent_id"
    t.datetime "fetched_at", :null => false
    t.string   "hostname"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
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
  end

  create_table "samples", :force => true do |t|
    t.integer  "metric_id"
    t.decimal  "value",      :precision => 14, :scale => 4
    t.datetime "created_at",                               :null => false
    t.datetime "updated_at",                               :null => false
    t.datetime "fetched_at"
  end

end
