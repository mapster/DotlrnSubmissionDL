class Menu

    def initialize
        @actions = self.methods.select { |m| m.to_s.start_with?("action_") }
        @run = true
    end

    def run?
        @run
    end

    def run!
        @run =  ! @run
    end

    def print_menu
        menu = @actions.map {|a| a.to_s.sub("action_","").gsub("_", " ").capitalize }
        i = 1
        menu.each {|m|
            puts "#{i}. #{m}\n"
            i += 1
        }
    end

    def action_quit
        @run = false
    end

    def read_int
        begin
            Integer(gets.strip)
        rescue
            puts "Not a valid number."
            read_int
        end
    end

    def display
        while run?
            print_menu
            print "Select action: "
            choice = read_int
            if choice > 0 && choice <= @actions.size
                ret = call_action(choice)
            else
                puts "Invalid action number."
            end
            puts "---"
        end
        ret
    end

    def call_action(index)
        self.send(@actions[index-1].to_sym)
    end

end

