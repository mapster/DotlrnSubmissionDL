#!/usr/bin/env ruby

require 'net/http'
require 'uri'

class MiSide
    LOGIN_URL = "https://miside.uib.no/register/user-login"

    def fetch(uri_str, limit = 10)
        # You should choose a better exception.
        raise ArgumentError, 'too many HTTP redirects' if limit == 0

        uri = URI.parse(uri_str)
        req = Net::HTTP::Get.new(uri.path)
        req.initialize_http_header({'Cookie' => @cookie}) unless @cookie.nil?

        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = uri.scheme == 'https'

        if block_given?
            yield http.request(req)
        else
            http.request(req)
        end
    end

    def followRedirect(response, limit = 10)
        case response
        when Net::HTTPSuccess then
            response
        when Net::HTTPRedirection then
            location = response['location']
            warn "redirected to #{location}"
            fetch(location, limit - 1) {|response| followRedirect(response)}
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
        followRedirect(response)
    end

end

