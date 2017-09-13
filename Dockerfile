FROM ruby:2.3.1

RUN apt-get update -qq && \
    apt-get install -y build-essential

WORKDIR /usr/src/app
COPY Gemfile* ./
RUN gem install bundler
RUN bundle install

COPY . ./

ENV PORT 4567
EXPOSE 4567
CMD ["ruby", "app.rb"]
