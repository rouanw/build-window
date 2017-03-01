FROM ruby:2.1.8-alpine

RUN apk update && \
    apk upgrade && \
    apk add bash curl-dev ruby-dev build-base nodejs && \
    rm -rf /var/cache/apk/* && \
    gem update --system 2.6.1 && \
    gem update bundler

COPY . /build-window

WORKDIR /build-window

RUN bundle install
