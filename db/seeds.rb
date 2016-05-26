# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
%w(kkaretnikov@weezlabs.com karetnikov.kirill@gmail.com).each do |user|
  user = User.create!(email: user, password: "password")
  puts "#{user.email} created!"
end
