require 'fileutils'
require 'io/console'

require 'menu/base'

class MainMenu < Menu

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
        return if start_index == -1 
        puts "Selected index #{start_index} (#{submissions[start_index].student})"

        select_menu = SelectSubMenu.new(submissions, start_index)
        puts "Select last student in range by: "
        end_index = select_menu.display
        return if end_index == -1
        puts "Selected index #{start_index} (#{submissions[start_index].student})"

        last = ""
        while start_index <= end_index && start_index < submissions.size
            s = submissions[start_index]
            path = "#{rootPath}/#{s.student.sub(", ", "-").gsub(" ", ".")}"
            FileUtils.mkdir_p(path) unless File.directory?(path)
            puts "Downloading: #{s.student} <#{s.file_name}>"

            datetime = DateTime.strptime(s.last_modified, '%d.%m.%y %H:%M').strftime("%Y-%m-%dT%H:%M")
            filepath = "#{path}/#{datetime}-#{s.file_name}"
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
        while number < 1
            print "Count must be larger than 0: "
            number = read_int
        end

        last = @submissions[@first].student
        index = @first
        current = @first +1
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

    def action_cancel
        self.run!
        -1
    end

    def action_quit
        exit
    end
end
