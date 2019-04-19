FROM ruby:2.6-slim as builder
RUN apt update && apt install -y \
      build-essential \
      && apt clean
RUN gem install bundler
WORKDIR /tmp
COPY Gemfile Gemfile.lock ./
ENV BUNDLE_JOBS=4
RUN bundle install

FROM ruby:2.6-slim
MAINTAINER Mahito <earthdragon77@gmail.com>
RUN apt update && apt install -y \
      locales-all \
      && apt clean
RUN gem install bundler &&  mkdir /slack-wormhole
WORKDIR /tmp
COPY --from=builder /usr/local/bundle /usr/local/bundle
WORKDIR /slack-wormhole
ADD lib ./lib
CMD ["bundle","exec", "ruby", "./lib/slack_wormhole.rb"]
