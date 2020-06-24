FROM ruby:2.6

RUN apt-get update && apt-get install -y --no-install-recommends apt-utils
RUN apt-get update && \
    apt-get -y install nodejs && \
    apt-get -y clean

RUN gem install bundler
COPY ./Gemfile /tmp
COPY ./Gemfile.lock /tmp
RUN cd /tmp && bundle install

WORKDIR /build-window
