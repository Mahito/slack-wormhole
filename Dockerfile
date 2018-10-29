FROM ruby:2.4
MAINTAINER Mahito <earthdragon77@gmail.com>
RUN apt update && apt upgrade -y && apt install -y locales locales-all

RUN mkdir /slack-wormhole
WORKDIR /slack-wormhole

COPY Gemfile Gemfile.lock ./
ADD lib ./lib
RUN bundle install

CMD ["bundle","exec", "ruby", "./lib/slack_wormhole.rb"]
