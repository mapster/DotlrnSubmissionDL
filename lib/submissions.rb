require 'nokogiri'

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

        owner_node = e.xpath('./td[@headers="contents_file_owner_name"]').first
        url_node   = e.xpath('./td[@headers="contents_name"]/a').first.attribute('href')
        file_node  = e.xpath('./td[@headers="contents_name"]/span').first
        modified_node = e.xpath('./td[@headers="contents_last_modified_pretty"]').first

        owner = owner_node.text.strip unless owner_node.nil?
        url = url_node.text.strip unless url_node.nil?
        file = file_node.text.strip unless file_node.nil?
        modified = modified_node.text.strip unless modified_node.nil?
        Submission.new(owner, url, file, modified)
    }
end

