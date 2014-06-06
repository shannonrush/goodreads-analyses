#!/usr/bin/env ruby

require 'csv'
require 'nokogiri'
require 'open-uri'
require 'pry'

load 'config_apis.rb'

user_id = 1

# id, name, gender, age, location, last_active, read_count, currently-reading_count, to-read_count
#
CSV.open("users.csv", "ab") do |csv|
    while user_id < 29000000
        puts user_id
        url = "http://www.goodreads.com/user/show/#{user_id}.xml?key=#{GOODREADS_KEY}"
        xml = Nokogiri::HTML(open(url)) rescue nil
        if xml
            user = xml.at_css("user")
            id = user.at_css("id").content rescue nil
            name = user.at_css("name").content rescue nil
            gender = user.at_css("gender").content rescue nil
            age = user.at_css("age").content rescue nil
            location = user.at_css("location").content rescue nil
            last_active = user.at_css("last_active").content rescue nil
            read_count = xml.xpath('//user_shelf[name="read"]/book_count').first.content rescue nil
            currently_reading_count = xml.xpath('//user_shelf[name="currently-reading"]/book_count').first.content rescue nil
            to_read_count = xml.xpath('//user_shelf[name="to-read"]/book_count').first.content rescue nil
            csv << [id,name,gender,age,location,last_active,read_count,currently_reading_count,to_read_count]
        end
        user_id += 1
    end
end

