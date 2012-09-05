#!/usr/bin/ruby

class Menu

    def initialize
        @actions = self.methods.select { |m| m.to_s.start_with?("action_") }
    end

    def print_menu
       menu = @actions.map {|a| a.to_s.sub("action_","").sub("_", " ").capitalize }
       i = 1
       menu.each {|m|
           puts "#{i}. #{m}\n"
           i += 1
       }
    end

    def action_quit
       exit 
    end

    def call_action(index)
       self.send(@actions[index-1].to_sym) 
    end

end

