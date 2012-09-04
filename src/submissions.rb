#!/usr/bin/env ruby

require 'nokogiri'
require 'rexml/document'
include REXML

class Submission
    attr_accessor :student
    attr_accessor :url
    attr_accessor :file_name
    attr_accessor :last_modified

    def initialize(student, url, file_name, last_modified)
        @student = student
        @url = url
        @file_name = file_name
        @last_modified = last_modified
    end
end

def get_submissions(html_string)
    html = Nokogiri::HTML(html_string)

    els = html.xpath('.//div[@id="folders"]/span/form/table/tbody/tr')
    submissions = els.map { |e|
        Submission.new(e.xpath('./td[@headers="contents_file_owner_name"]').first.text.strip,
                       e.xpath('./td[@headers="contents_name"]/a').first.attribute('href').text.strip,
                       e.xpath('./td[@headers="contents_name"]/span').first.text.strip,
                       e.xpath('./td[@headers="contents_last_modified_pretty"]').first.text.strip)
    }
end

