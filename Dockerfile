FROM circleci/ruby:2.6.3
# Add source for the latest stable NodeJS
RUN curl -sL https://deb.nodesource.com/setup_10.x | sudo -E bash -
# Add source for the latest stable Yarn
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
RUN echo "deb http://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
RUN sudo apt-get update && sudo apt-get install build-essential git nodejs yarn
RUN gem install bundler
RUN bundle config build.nokogiri --use-system-libraries
