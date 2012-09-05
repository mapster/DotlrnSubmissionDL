#!/usr/bin/ruby

require 'fileutils'
require 'io/console'
require 'yaml'

require 'miside/base'
require 'submissions.rb'
require 'menus'

#setup auth
auth_file = (File.dirname(__FILE__) + "/../.auth.yaml")
if File.exist?(auth_file)
    auth = YAML::load(File.open(auth_file, "r").read)
else
    auth = Auth.new
    print "Email: "
    auth.email = gets.strip

    print "Password: "
    auth.password = STDIN.noecho(&:gets).strip
    puts ""
end

miside = MiSide.new
puts miside.login(auth)

puts "Url for submission folder: "
submissionUrl = gets

m = MyMenu.new(miside, submissionUrl)
m.display

exit
