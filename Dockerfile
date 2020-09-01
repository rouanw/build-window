FROM ruby:2.6

RUN apt-get update && apt-get install -y --no-install-recommends apt-utils
RUN apt-get update && \
    apt-get -y install nodejs && \
    apt-get -y clean

RUN gem install bundler
RUN mkdir /build-window
COPY ./Gemfile /build-window
RUN cd /build-window && bundle install

WORKDIR /build-window
