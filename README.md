DotlrnSubmissionDL
==================

Install:
--------
1. Make sure ruby and rubygems is installed.
2. Install bundler gem
    `$ gem install bundler`
3. Make sure PATH includes the gem bin path:

    ~/.gem/1.9.1/bin (or some other version)
    `$ export PATH=$PATH:$(ruby -rubygems -e "puts Gem.user_dir")/bin`
    To make it persistent add the previous line to your ~/.bashrc or ~/.profile

4. Install the required gems
    `bundle install`
5. Execute
    `$ ./bin/dotlrnSubmissionDL`
