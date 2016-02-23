FROM ruby:2.1.8-alpine

RUN apk update && \
    apk upgrade && \
    apk add bash curl-dev ruby-dev build-base nodejs && \
    rm -rf /var/cache/apk/*

COPY . /build-window

WORKDIR /build-window

RUN bundle install
