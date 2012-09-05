#!/usr/bin/ruby

require 'fileutils'
require 'io/console'

require 'miside.rb'
require 'submissions.rb'
require 'menu.rb'

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
        submissions = fetch_submissions

        print "Path to store downloads: "
        rootPath = gets.strip

        select_menu = SelectSubMenu.new(submissions)
        puts "Select first student in range by: "
        start_index = select_menu.display
        puts "Selected index #{start_index} (#{submissions[start_index].student})"

        select_menu = SelectSubMenu.new(submissions, start_index)
        puts "Select last student in range by: "
        end_index = select_menu.display
        puts "Selected index #{start_index} (#{submissions[start_index].student})"

        last = ""
        while start_index <= end_index && start_index < submissions.size
            s = submissions[start_index]
            path = "#{rootPath}/#{s.student.sub(", ", ".")}"
            FileUtils.mkdir_p(path) unless File.directory?(path)
            puts "Downloading: #{s.student} <#{s.file_name}>"

            filepath = "#{path}/#{s.last_modified}-#{s.file_name}"
            open(filepath, "wb") {|file|
                file.write(@miside.fetch_submission(s.url).body)
            }

            start_index += 1
            last = s.student
        end
    end

end

class SelectSubMenu < Menu
    def initialize(submissions, first = 0)
        super()
        @submissions = submissions
        @first = first
    end

    def action_by_index
        print "Enter index: "
        index = read_int
        if index < @first || index >= @submissions.size 
            puts "Invalid index, should be in interval [#{@first}, #{@submissions.size-1}]"
        else
            self.run!
        end
        index
    end

    def action_by_student_count
        print "Enter student count (i.e the xth student): "
        number = read_int
        last = @submissions[0].student
        index = 0
        current = 1
        while number > 1 && current < @submissions.size
            s = @submissions[current]
            if last != s.student
                number -= 1 
                index = current
            end
            current += 1
            last = s.student
        end
        self.run!
        index
    end

    def action_by_name
        print "Enter name of first student (surname, firstname ...): "
        name = gets.strip
        result = search(name)
        if result.size > 1
            puts "#{result.size} results, be more precise."
            result.each {|r|
                puts r.student
            }
            action_by_name
        elsif result.size == 0
            puts "0 found."
            action_by_name
        elsif @submissions.index(result.first) < @first
            puts "Found student has a lower index (#{@submissions.index(result.first)}) than the first (#{@first})"
            action_by_name
        else
            self.run!
            @submissions.index(result.first)
        end
    end

    def search(name)
        selected = Array.new
        @submissions.select {|s| 
            add = false
            if s.student.start_with?(name) 
                if not selected.include?(s.student)
                    selected << s.student
                    add = true
                end
            end
            add 
        }
    end
end
print "Email: "
email = gets.strip

print "Password: "
password = STDIN.noecho(&:gets).strip

miside = MiSide.new
puts miside.login(email, password)

puts "Url for submission folder: "
submissionUrl = gets

m = MyMenu.new(miside, submissionUrl)
m.display

exit
