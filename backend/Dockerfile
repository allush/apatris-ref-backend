FROM ruby:2.7.3

RUN apt-get update && apt-get install -y --no-install-recommends apt-utils
RUN apt-get install graphviz -y
RUN gem update bundler && gem update --system

# throw errors if Gemfile has been modified since Gemfile.lock
RUN bundle config --global frozen 1

WORKDIR /app

ENV BUNDLE_PATH=/app/vendor/bundle
ENV PATH=$PATH:/app/bin

EXPOSE 9000

CMD ["bundle", "exec", "rails", "s", "-p", "9000", "-b", "0.0.0.0", "--pid", "/dev/null"]
