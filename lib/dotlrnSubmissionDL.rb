require 'fileutils'
require 'io/console'
require 'yaml'

require 'miside/base'
require 'submissions'
require 'menus'

#setup auth
auth_file = (File.dirname(__FILE__) + "/../.auth.yaml")
if File.exist?(auth_file)
    auth = YAML::load(File.open(auth_file, "r").read)
else
    print "Email: "
    email = gets.strip

    print "Password: "
    password = STDIN.noecho(&:gets).strip
    puts ""

    auth = Auth.new(email, password)
end

miside = MiSide.new
puts miside.login(auth)

puts "Url for submission folder: "
submissionUrl = gets

m = MainMenu.new(miside, submissionUrl)
m.display

exit
