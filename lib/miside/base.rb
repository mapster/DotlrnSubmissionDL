require 'net/http'
require 'uri'

require 'miside/auth'

module URI
    class << self
        def parse_with_safety(uri)
            parse_without_safety uri.gsub('[', '%5B').gsub(']', '%5D')
        end

        alias parse_without_safety parse
        alias parse parse_with_safety
    end
end


class MiSide
    class LoginError < RuntimeError
    end

    LOGIN_URL = "https://miside.uib.no/register/user-login"
    LOGIN_URI = URI.parse(LOGIN_URL)

    def fetch_submission(path)
        fetch ("#{LOGIN_URI.scheme}://#{LOGIN_URI.host}#{path}") {|response|
            follow_redirect(response)
        }
    end

    def fetch(uri_str)
        uri = URI.parse(URI.encode(uri_str))
        req = Net::HTTP::Get.new(uri.request_uri)
        req.initialize_http_header({'Cookie' => @cookie}) unless @cookie.nil?

        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = uri.scheme == 'https'

        if block_given?
            yield http.request(req)
        else
            http.request(req)
        end
    end

    def follow_redirect(response, limit = 10)
        raise ArgumentError, 'too many HTTP redirects' if limit == 0

        case response
        when Net::HTTPSuccess then
            response
        when Net::HTTPRedirection then
            location = response['location']
            fetch(location) {|response| follow_redirect(response, limit -1)}
        else
            response
        end
    end

    def login(auth)
        uri = URI.parse(LOGIN_URL)
        req = Net::HTTP::Post.new(uri.path)
        req.form_data = auth.get_hash 

        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl= uri.scheme == 'https'

        response = http.request(req)
        @cookie = response['Set-Cookie']
        response = follow_redirect(response)

        case response
        when Net::HTTPInternalServerError then
            #not entirely correct
            raise LoginError, "Invalid username/password combination"
        when Net::HTTPSuccess then
            "Successfully logged in."
        else
            raise LoginError, "Unknown error."
        end
    end

end

