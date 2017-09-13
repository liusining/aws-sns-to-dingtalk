FROM ruby:2.3.1

RUN apt-get update -qq && \
    apt-get install -y build-essential

WORKDIR /usr/src/app
COPY Gemfile* ./
RUN gem install bundler
RUN bundle install

COPY . ./

EXPOSE 4567
CMD ["bundle", "exec", "rackup", "config.ru", "-p", "4567", "-s", "thin", "-o", "0.0.0.0"]
