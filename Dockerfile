FROM ruby:2.6

RUN apt-get update && apt-get install -y --no-install-recommends apt-utils
RUN apt-get update && \
    apt-get -y install nodejs && \
    apt-get -y clean

COPY . /build-window

WORKDIR /build-window

RUN bundle install
