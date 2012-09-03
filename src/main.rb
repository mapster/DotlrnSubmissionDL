#!/usr/bin/ruby

require './miside.rb'

puts "Email: "
email = gets.strip
puts "Password: "
password = gets.strip

miside = MiSide.new
puts miside.login(email, password)

puts "Url for submission folder: "
submissionsUrl = gets

miside.fetch(submissionsUrl) {|response|
    case response
    when Net::HTTPSuccess then
        open("content.html", "wb") {|file|
            file.write(response.body)
        }
    else
        puts "Unable to fetch folder contents: #{response.code} #{response.msg}}"
    end
}
