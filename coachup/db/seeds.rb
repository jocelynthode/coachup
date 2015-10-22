# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
# ruby encoding: utf-8
Course.create(title: "Taekwondo 101", description: "It's a course aimed at beginners",
              price: 0, coach_id: 1, created_at: DateTime.now, updated_at: DateTime.now,
              sport: "Boxing")