#!/usr/bin/ruby

require 'fileutils'
require 'io/console'
require 'yaml'

require 'miside.rb'
require 'submissions.rb'
require 'menus'

class Auth 
    attr_reader :email, :password
    def initialize(email, password)
        @email = email
        @password = password
    end
end

auth_file = (File.dirname(__FILE__) + "/../.auth.yaml")
if File.exist?(auth_file)
    auth = YAML::load(File.open(auth_file, "r").read)
else
    print "Email: "
    email = gets.strip

    print "Password: "
    password = STDIN.noecho(&:gets).strip
end

miside = MiSide.new
puts miside.login(email, password)

puts "Url for submission folder: "
submissionUrl = gets

m = MyMenu.new(miside, submissionUrl)
m.display

exit
