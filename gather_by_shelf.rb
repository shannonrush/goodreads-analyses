#!/usr/bin/env ruby

require 'csv'
require 'nokogiri'
require 'open-uri'
require 'pry'

load 'config_apis.rb'

SHELVES = {"read"=>6,"currently-reading"=>7,"to-read"=>8}

# user_id, book_id, date_added, started_at, read_at, 

class GatherShelf
    def self.gather_shelf(shelf)
        shelf_index = SHELVES[shelf]
        CSV.foreach("users.csv") do |user|
            if user[shelf_index].to_i > 0
                user_id = user[0]
                CSV.open("#{shelf}.csv","ab") do |csv|
                    url = "https://www.goodreads.com/review/list/#{user[0]}.xml?key=#{GOODREADS_KEY2}&v=2&shelf=#{shelf}"
                    xml = Nokogiri::HTML(open(url)) rescue nil
                    if xml
                        reviews = xml.css("review")
                        reviews.each do |review|
                            date_added = review.at_css("date_added").content rescue nil
                            started_at = review.at_css("started_at").content rescue nil
                            read_at = review.at_css("read_at").content rescue nil
                            book = review.at_css("book")
                            book_id = book.at_css("id").content rescue nil
                            isbn = book.at_css("isbn").content rescue nil
                            isbn13 = book.at_css("isbn13").content rescue nil
                            title = book.at_css("title").content rescue nil
                            image_url = book.at_css("image_url").content rescue nil
                            num_pages = book.at_css("num_pages").content rescue nil
                            publisher = book.at_css("publisher").content rescue nil
                            publication_year = book.at_css("publication_year").content rescue nil
                            genres = GatherShelf.get_genres(book_id) 
                            puts title
                            puts genres
                            csv << [user_id,book_id,shelf,date_added,started_at,read_at,title,isbn,isbn13,image_url,num_pages,publisher,publication_year,genres]                            
                        end
                    end
                end
            end
        end
    end

    def self.get_genres(book_id)
        url = "http://www.goodreads.com/book/show/#{book_id}?format=xml&key=#{GOODREADS_KEY2}"
        xml = Nokogiri::HTML(open(url)) rescue nil
        if xml
            genres = []
            shelves = xml.css("shelf")
            shelves.each do |shelf|
                unless SHELVES.keys.include?(shelf["name"])
                    genres << shelf["name"]
                end
            end    
            return genres
        end 
        return nil
    end
end


GatherShelf.gather_shelf(ARGV[0])

