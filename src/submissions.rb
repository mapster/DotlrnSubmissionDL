#!/usr/bin/env ruby

require 'rexml/document'
include REXML

class Submission
    attr_accessor :student
    attr_accessor :url

    def initialize(student, url)
        @student = student
        @url = url
    end
end

xmlfile = File.new("oving1.xhtml")
xmldoc = Document.new(xmlfile)

els = XPath.match(xmldoc, '//[@id="folders"]/form/table/tbody/tr')
puts els.size
c = 0
submissions = els.map { |e|
    Submission.new(e.elements.to_a('./td[@headers="contents_file_owner_name"]').first.text.strip, 
                   e.elements.to_a('./td[@headers="contents_name"]/a').first.attributes['href'])
}


