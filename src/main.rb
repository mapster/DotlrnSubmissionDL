#!/usr/bin/ruby

require 'fileutils'
require 'io/console'

require './miside.rb'
require './submissions.rb'


class Menu

    def initialize
        @actions = self.methods.select { |m| m.to_s.start_with?("action_") }
    end

    def print_menu
       puts "Select an action: "
       menu = @actions.map {|a| a.to_s.sub("action_","").sub("_", " ").capitalize }
       i = 0
       menu.each {|m|
           puts "#{i}. #{m}\n"
           i += 1
       }
    end

    def action_quit
       exit 
    end

    def call_action(index)
       self.send(@actions[index].to_sym) 
    end

end

class MyMenu < Menu

    def initialize(miside, submissionUrl)
        super()
        @miside = miside
        @submissionUrl = submissionUrl
    end

    def fetch_submissions
        r = @miside.fetch(@submissionUrl) {|r| @miside.follow_redirect(r)}
        get_submissions(r.body)
    end

    def action_list_submissions
        i = 0
        fetch_submissions.each {|s|
            puts "#{i} #{s.student} <#{s.file_name}>"
            i += 1
        }
    end

    def action_download
       puts "Path to store downloads: "
       rootPath = gets.strip

       puts "Start index (zero-based): "
       start = Integer(gets)

       puts "Number of students: "
       count = Integer(gets)

       submissions = fetch_submissions
       last = ""
       while count > 0
           s = submissions[start]
           path = "#{rootPath}/#{s.student.sub(", ", ".")}"
           FileUtils.mkdir_p(path) unless File.directory?(path)
           puts "Downloading: #{s.student} <#{s.file_name}>"

           filepath = "#{path}/#{s.last_modified}-#{s.file_name}"
           open(filepath, "wb") {|file|
               file.write(@miside.fetch_submission(s.url).body)
           }

           count -= 1 unless last == s.student
           start += 1
           last = s.student
       end
    end
end

puts "Email: "
email = gets.strip
puts "Password: "
password = STDIN.noecho(&:gets).strip

miside = MiSide.new
puts miside.login(email, password)

puts "Url for submission folder: "
submissionUrl = gets

m = MyMenu.new(miside, submissionUrl)
while true
    m.print_menu
    m.call_action(Integer(gets))
end

exit


