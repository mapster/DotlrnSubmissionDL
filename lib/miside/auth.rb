class Auth 
    attr_reader :email, :password
    def initialize(email, password)
        @email = email
        @password = password
    end

    def get_hash
        {'email' => @email, 'password' => @password}
    end

end
