#!/usr/bin/env ruby

require 'net/http'
require 'uri'

LOGIN_URL = "https://miside.uib.no/register/user-login"

def fetch(uri_str, limit = 10)
      # You should choose a better exception.
       raise ArgumentError, 'too many HTTP redirects' if limit == 0
    
       uri = URI.parse(uri_str)
       req = Net::HTTP::Get.new(uri.path)
       req.initialize_http_header({'Cookie' => @cookie}) unless @cookie.nil?

       http = Net::HTTP.new(uri.host, uri.port)
       http.use_ssl = uri.scheme == 'https'
       yield http.request(req)
end

def followRedirect(response)
       case response
       when Net::HTTPSuccess then
           response
       when Net::HTTPRedirection then
           location = response['location']
           warn "redirected to #{location}"
           fetch(location, limit - 1)
       else
           response
       end
end

def login(email, password)
    uri = URI.parse(LOGIN_URL)
    req = Net::HTTP::Post.new(uri.path)
    req.form_data = {'email' => email, 'password' => password, 'domain' => 'student'}

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl= uri.scheme == 'https'
    
    response = http.request(req)
    @cookie = response['Set-Cookie']
    yield response
end


def post(uri_str, data, limit = 10)
      # You should choose a better exception.
       raise ArgumentError, 'too many HTTP redirects' if limit == 0
    
       uri = URI.parse(uri_str)
       req = Net::HTTP::Post.new(uri.path)
       req.form_data = data

       http = Net::HTTP.new(uri.host, uri.port)
       http.use_ssl= uri.scheme == 'https'
       response = http.request(req)

       case response
       when Net::HTTPSuccess then
           response
       when Net::HTTPRedirection then
           location = response['location']
           warn "redirected to #{location}"
           fetch(location, response['Set-Cookie'], limit - 1)
       else
           response.value
       end
end


#puts post("https://miside.uib.no/register/user-login", {'email' => 'aro037@student.uib.no', 'password' => '', 'domain' => 'student'}).body
#puts fetch("https://miside.uib.no/dotlrn/classes/det-matematisk-naturvitenskapelige-fakultet/inf100/inf100-2012h/dotlrn-homework/folder-contents?folder_id=99855833&return_url=%2fdotlrn%2fclasses%2fdet-matematisk-naturvitenskapelige-fakultet%2finf100%2finf100-2012h%2fone-community%3fpage_num%3d0&homework_user_id=").body

#uri = URI('https://miside.uib.no/register/user-login?locale=')
#req = Net::HTTP::Post.new(uri.path)
#req.form_data = {'email' => 'aro037@student.uib.no', 'password' => '', 'domain' => 'student'}
#
#h = Net::HTTP.new(uri.host, uri.port)
#h.use_ssl=true
##h.set_debug_output $stderr
#res = h.start {|http|
#    http.request(req)
#}


